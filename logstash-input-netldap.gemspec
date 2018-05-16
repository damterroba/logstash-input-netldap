Gem::Specification.new do |s|
  s.name = 'logstash-input-netldap'
  s.version         = '1.0.4'
  s.licenses = ['Apache-2.0']
  s.summary = "Logstash input plugin that performs an LDAP search."
  s.description     = "This gem is a Logstash input plugin allowing to retrieve entries from a LDAP directory. This gem has to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["damterroba"]
  s.email = 'mathieu.terroba@gmail.com'
  s.homepage = "https://github.com/damterroba/logstash-input-netldap/"
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.0.0"

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input", "documentation_uri" => "https://github.com/damterroba/logstash-input-netldap/blob/master/docs/index.asciidoc" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  s.add_runtime_dependency 'net-ldap', '>= 0.16.1'
  s.add_runtime_dependency 'rufus-scheduler'
  s.add_development_dependency 'logstash-devutils'
end
