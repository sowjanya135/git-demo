provider "aws" {
region = "us-east-2"
}
resource "aws_imagebuilder_component" "tomcat" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        name   = "Installjava"
        action = "ExecuteBash"
        inputs = {
          commands = [
            "sudo yum update -y",
            "sudo amazon-linux-extras install java-openjdk11 -y"
          ]
        }
        name   = "Installwebserver"
        action = "ExecuteBash"
        inputs = {
          commands = [
            "wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.0.8/bin/apache-tomcat-10.0.8.tar.gz",
            "sudo tar xzvf apache-tomcat-10.0.8.tar.gz",
            "sudo mkdir /opt/tomcat/",
            "sudo mv apache-tomcat-10.0.8/* /opt/tomcat/",
            "sudo useradd tomcat",
            "sudo chown -R tomcat:tomcat /opt/tomcat/",
            "sudo chmod -R 755 /opt/tomcat/",
            "touch /etc/systemd/system/tomcat.service",
           # "echo "export CATALINA_HOME=/opt/tomcat" >> /etc/systemd/system/tomcat.service",
            #"echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.13.0.8-1.amzn2.0.3.x86_64" >> /etc/systemd/system/tomcat.service",
            "export CATALINA_HOME=/opt/tomcat >> /etc/systemd/system/tomcat.service",
            "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.13.0.8-1.amzn2.0.3.x86_64 >> /etc/systemd/system/tomcat.service",
            "export ExecStart=/opt/tomcat/bin/startup.sh >> /etc/systemd/system/tomcat.service",
            "export ExecStart=/opt/tomcat/bin/shutdown.sh >> /etc/systemd/system/tomcat.service"
          ]
        }
       # name   = "MovingAFileLinuxMovingAFileLinux"
        #action = "MoveFile"
       # inputs = {
        #  source = "/home/ec2-user/webservers/tomcat/jdk11/tomcat.service"
         # destination = "/etc/systemd/system/tomcat.service"
        #}
        name   = "starttomcatservice"
        action = "ExecuteBash"
        inputs = {
          commands = [
            "sudo /opt/tomcat/bin/startup.sh"
          ]
        }
      }]
    }]
    schemaVersion = 1.0
  })
  name     = "tomcat"
  platform = "Linux"
  version  = "1.0.0"
}
