nodemailer = require 'nodemailer'
fs = require 'fs'
mustache = require 'mustache'
util = require '../util'

class EmailHelper

  @configure: (settings)=>
    if settings?
      @settings = settings
    else if config.get('email')?
      @emailConf = config.get('email')
      @emailConf = util.clone(@emailConf)
      @settings = @emailConf.server
      @settings = util.clone(@settings)

  @getTransporter: ()->
    @configure() unless @settings?
    @transporter = nodemailer.createTransport(@settings) unless @transporter?
    return @transporter

  @send: (toAddress, subject, body, cb)=>
    transporter = @getTransporter()

    mailOptions = {
      from: @emailConf.from_address
      to: toAddress
      subject: subject
      html: body
    }
    transporter.sendMail mailOptions, (e, info)->
      cb e, info

  @getTemplateDir: ()->
    return __dirname + '/../mail/'

  @getRenderedTemplate: (template, data)->
    path = @getTemplateDir() + template + '.mustache'
    template = fs.readFileSync(path, 'utf8')
    return mustache.render(template, data)

  @sendWithTemplate: (toAddress, subject, template, data, cb)->
    body = @getRenderedTemplate template, data
    @send toAddress, subject, body, cb

module.exports = EmailHelper