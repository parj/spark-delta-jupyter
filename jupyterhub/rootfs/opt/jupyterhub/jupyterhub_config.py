c = get_config()  #noqa

c.Spawner.notebook_dir = "~/"
c.NotebookApp.token = ''
c.NotebookApp.terminals_enabled = False
c.Authenticator.admin_users = {'spark'}
c.JupyterHub.authenticator_class = 'dummy'