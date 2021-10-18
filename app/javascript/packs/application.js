import "homeland/index"
import "front/index"
import 'homeland-activities/controllers'
import { Application } from "stimulus"
import CheckboxSelectAll from "stimulus-checkbox-select-all"

import Sortable from "stimulus-sortable"
import { definitionsFromContext } from "stimulus/webpack-helpers"
require("jquery")
require("@nathanvda/cocoon")

const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.register("checkbox-select-all", CheckboxSelectAll)
application.register("sortable", Sortable)


application.load(definitionsFromContext(context))