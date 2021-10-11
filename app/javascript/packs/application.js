import "homeland/index"
import "front/index"
import 'homeland-activities/controllers'
import { Application } from "stimulus"
import CheckboxSelectAll from "stimulus-checkbox-select-all"


import { definitionsFromContext } from "stimulus/webpack-helpers"

const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.register("checkbox-select-all", CheckboxSelectAll)


application.load(definitionsFromContext(context))