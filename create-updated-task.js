'use strict'

const fs = require('fs')

const task = require('./task-definition.json')
const updatedTask = task
const repo = 'ecs-webserver'

const url = `${process.env.AWS_ACCOUNT_ID}.dkr.ecr.${process.env.AWS_DEFAULT_REGION}.amazonaws.com`

const image = `${url}/${repo}:${process.env.CIRCLE_SHA1}`

updatedTask.containerDefinitions[0].image = image

updatedTask.containerDefinitions[0].environment = [
  {
    'name': 'NODE_ENV',
    'value': 'staging',
  },
]

updatedTask.containerDefinitions[0].logConfiguration.options = {
  'awslogs-group': process.env.STAGING_WEB_AWSLOGS_GROUP,
  'awslogs-region': process.env.STAGING_WEB_AWSLOGS_REGION,
  'awslogs-stream-prefix': process.env.STAGING_WEB_AWSLOGS_PREFIX,
}

const jsonTask = JSON.stringify(updatedTask)

fs.writeFile('updated-task.json', jsonTask, 'utf8')
