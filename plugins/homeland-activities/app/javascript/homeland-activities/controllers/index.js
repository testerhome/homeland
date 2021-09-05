import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import './slide_controller.js'
import './events.scss'
import  'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css'

const application = Application.start()
const context = require.context(".", true, /_controller\.js$/)
application.load(definitionsFromContext(context))