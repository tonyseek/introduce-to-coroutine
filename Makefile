VENV_DIR = venv
VENV_USE = $(VENV_DIR)/bin/activate
WITH_ENV = source $(VENV_USE);

venv: $(VENV_USE)

$(VENV_USE):
	virtualenv -p python2.7 $(VENV_DIR)
	echo "introduce-to-corotinue" > $(VENV_DIR)/__name__
	$(WITH_ENV) pip install -U -r pip-req.txt

build:
	echo "todo"
