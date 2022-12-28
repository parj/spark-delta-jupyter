c = get_config()  #noqa

c.Spawner.notebook_dir = "~/"
c.NotebookApp.token = ''
c.JupyterHub.cookie_secret_file = '/home/spark/jupyterhub_cookie_secret'
c.Authenticator.admin_users = {'spark'}
c.JupyterHub.authenticator_class = 'dummy'