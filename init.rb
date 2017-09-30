#Set global variables
$config_dir = Dir.home + '/.crypto_trader'
$config_file = $config_dir + '/conf.yml'
$temp_dir = $config_dir + '/tmp'
$log_dir = $config_dir + '/log'
$template_dir = $config_dir + '/templates'
#Some constants
NEW_LINE = "\n"
LINE_SEPARATOR = '---------------------------------------------------------'
#Create default folders if doesn't exist
Dir.mkdir($config_dir) unless File.exist?($config_dir)
Dir.mkdir($log_dir) unless File.exist?($log_dir)
Dir.mkdir($temp_dir) unless File.exist?($temp_dir)
unless File.exist?($template_dir)
  FileUtils.cp_r File.dirname(__FILE__) + '/config/templates/', $template_dir
end
$logger = Logger.new($log_dir + '/crypto_trader.log')
$logger_error = Logger.new($log_dir + '/crypto_trader_errors.log')
#Load app and settings
Dir[File.dirname(__FILE__) + '/app/*.rb'].each { |file| require file }
Config.load_settings

#Configure email alerts
$email_templates = File.dirname(__FILE__) + '/app/mailer_templates'
Dir.mkdir($mail_templates) unless File.exist?($email_templates)
$email = $config['email']
if $email
  Hanami::Mailer.configure do
    root $email_templates
    delivery_method :smtp,
                    address:              $email['host'],
                    port:                 $email['port'],
                    domain:               $email['domain'],
                    user_name:            $email['username'],
                    password:             $email['password'],
                    authentication:       $email['auth_type'],
                    enable_starttls_auto: true
  end.load!
end

#String comparator
$str_closeness = FuzzyStringMatch::JaroWinkler.create( :pure )