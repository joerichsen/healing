
cloud :dev do
  uuid 'hjujj3j'
  key '/Users/emiltin/.ec2/testpair'
  instances 1
  availability_zone 'us-east-1a'
  
  mysql_ebs 'vol-4943a020'
  rails_app '/rails_app', :repo => 'git://github.com/emiltin/poolparty_example.git'  
end
