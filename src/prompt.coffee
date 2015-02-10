module.exports =
  questions: [
    {
      message: 'Framework to use?'
      name: 'framework'
      type: 'list'
      choices: [
        {
          name: 'Angular.js'
          value: 'angular'
        }
        {
          name: 'React.js'
          value: 'react'
        }
        {
          name: 'Ember.js'
          value: 'ember'
        }
        {
          name: 'None'
          value: 'none'
        }
      ],
    }
      {
        message: 'Template?'
        name: 'template'
        type: 'list'
        choices: [
          {
            name: 'Bootstrap'
            value: 'bootstrap'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'Javascript preprocessor?'
        name: 'javascript'
        type: 'list'
        default: 'javascript'
        choices: [
          {
            name: 'CoffeeScript'
            value: 'coffeescript'
          }
          {
            name: 'None'
            value: 'javascript'
          }
        ],
      }
      {
        message: 'HTML preprocessor?'
        name: 'html'
        type: 'list'
        default: 'html'
        choices: [
          {
            name: 'Jade'
            value: 'jade'
          }
          {
            name: 'None'
            value: 'html'
          }
        ]
      }
      {
        message: 'CSS preprocessor?'
        name: 'css'
        type: 'list'
        default: 'css'
        choices: [
          {
            name: 'SCSS'
            value: 'scss'
          }
          {
            name: 'None'
            value: 'css'
          }
        ]
      }
    ]
