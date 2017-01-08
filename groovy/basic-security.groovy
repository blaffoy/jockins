#!groovy
import hudson.security.*
import jenkins.model.*

Properties properties = new Properties()
File propertiesFile = new File('/secrets/secrets.env')
propertiesFile.withInputStream {
    properties.load(it)
}

String username = properties.'JENKINS_ADMIN'
String password = properties.'ADMIN_PASSWORD'

def instance = Jenkins.getInstance()

println "--> Checking if security has been set already"

if (!instance.isUseSecurity()) {
    println "--> creating local user '$username'"

    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount(username, password)
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
}
