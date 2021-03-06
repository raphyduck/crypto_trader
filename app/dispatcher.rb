class Dispatcher

  def self.available_actions
    {
        :help => ['Dispatcher', 'show_available'],
        :reconfigure => ['Config', 'reconfigure'],
        :usage => ['Dispatcher', 'show_available']
    }
  end

  def self.dispatch(args, actions = self.available_actions, parent = nil)
    arg = args.shift
    actions.each do |k, v|
      if arg == k.to_s
        if v.is_a?(Hash)
          self.dispatch(args, v, "#{parent} #{arg}")
        else
          self.launch(v, args, "#{parent} #{arg}")
        end
        return
      end
    end
    Speaker.speak_up('Unknown command/option

')
    self.show_available(actions, parent)
  end

  def self.launch(action, args, parent)
    args = Hash[args.flat_map { |s| s.scan(/--?([^=\s]+)(?:=(.+))?/) }]
    template_args = Utils.load_template(args['template_name'])
    model = Object.const_get(action[0])
    req_params = model.method(action[1].to_sym).parameters.map { |a| a.reverse! }
    req_params.each do |param|
      return self.show_available(Hash[req_params.map { |k| ["--#{k[0]}=<#{k[0]}>", k[1]] }], parent, ' ') if param[1] == :keyreq && args[param[0].to_s].nil? && template_args[param[0].to_s].nil?
    end
    $email_msg = $email ? '' : nil
    $email_msg = nil if args['email_notif'].to_i > 0 || template_args['email_notif'].to_i > 0
    $action = action[0] + ' ' + action[1]
    dameth = model.method(action[1])
    params = Hash[req_params.map { |k, _| [k, args[k.to_s] || template_args[k.to_s]] }].select { |_, v| !v.nil? }
    params.empty? ? dameth.call : dameth.call(params)
  rescue => e
    Speaker.tell_error(e, "Dispatcher.launch")
  end

  def self.show_available(available = self.available_actions, prepend = nil, join='|')
    Speaker.speak_up("Usage: trader #{prepend + ' ' if prepend}#{available.map { |k, v| "#{k.to_s}#{'(optional)' if v == :opt}" }.join(join)}")
    Speaker.speak_up(LINE_SEPARATOR)
    Speaker.speak_up("Tip: You can use the extra argument '--template_name=<template_name>' to specify the name of a YAML file stored in ~/.medialibrarian/templates/name.yml that will contain all your desired arguments. This allow to launch an action without repeting the same logn list of arguments.")
  end
end