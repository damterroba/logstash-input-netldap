# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require "base64"
require "rubygems"
require "net/ldap"

# Performs a LDAP search using net-ldap. 
#
# Usage : 
#
# input {
#   ldap{
#     host => "myLdapHost"
#     port => 389
#     dn => "myDn"
#     password => "myPassword"
#     base => "ou=people,dc=gouv,dc=fr"
#     filter => [{field=>"field1" value=>"value1"}, {field=>"field2" value=>"value2"}
#     attrs => ['uid', 'mail', 'sn', 'cn']
#   } 
# }
#

class LogStash::Inputs::NetLdap < LogStash::Inputs::Base
  config_name "netldap"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  # The ldap host to perform the search
  # Can be ip or hostname
  config :ldap_host, :validate => :string, :required => true

  # The ldap port to connect on, 389 by default
  config :port, :validate => :number, :default => 389, :required => true

  # Specifies if the bind is anonymous
  # If not, you'll need to set the user bind DN and password
  config :anonymous, :validate => :boolean, :default => false

  # User to bind an the ldap server
  config :dn, :validate => :string

  # Configure the password
  config :password, :validate => :password

  # LDAP base DN to search in
  config :base, :validate => :string, :required => true

  # Filters of the ldap search, an array of hashes
  config :filters, :validate => :array, :default => [{ "field" =>  "objectclass", "value" => "inetorgperson" }]

  # Specify the attributes you wanna get for each entry
  config :attrs, :validate => :array, :default => ["uid", "mail"]

  public
  def register
    @host = Socket.gethostname
    
    if @anonymous
      auth = { :method => :anonymous}
    else
      auth = {
        :method => :simple,
        :username => @dn,
        :password => @password.value  
      }
    end
    @conn = Net::LDAP.new :host => @ldap_host,
    :port => @port,
    :auth => auth
  end

  def run(queue)
    # Filters def
    finalFilter = "" # need to initialize this outside the each
    @filters.each.with_index do |hashFilter, index|
      tmpFilter = Net::LDAP::Filter.eq(hashFilter['field'], hashFilter['value'])
      case index
      when 0
        finalFilter = tmpFilter
      else
        finalFilter = Net::LDAP::Filter.join(finalFilter, tmpFilter)
      end
    end

    #filter = Net::LDAP::Filter.eq("objectclass", "inetorgperson")
    @conn.search(:base => @base, :filter => finalFilter, :attributes => @attrs) do |entry|
      # event = LogStash::Event::new
      event = LogStash::Event.new()
      decorate(event)
      entry.each do |attribute, value|
        if value.count() > 1
          event.set("#{attribute}", value)
        else
          event.set("#{attribute}", value.first)
        end
      end
      queue << event
    end
  end 
end
