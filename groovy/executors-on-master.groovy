import jenkins.model.Jenkins;
def instance = Jenkins.getInstance();
instance.setNumExecutors(1);
