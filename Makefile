VENV_DIR = venv
VENV_USE = $(VENV_DIR)/bin/activate
WITH_ENV = source $(VENV_USE);

DOCS_DIR = docs
WITH_DOC = cd $(DOCS_DIR);

BUILD = $(WITH_ENV) $(WITH_DOC) $(MAKE) $(MFLAGS)

all: build
venv: $(VENV_USE)

$(VENV_USE):
	@echo "=> Creating virtual environment..."
	virtualenv -p python2.7 $(VENV_DIR)
	echo "introduce-to-corotinue" > $(VENV_DIR)/__name__
	@echo "=> Installing requirements..."
	$(WITH_ENV) pip install -U -r pip-req.txt
	@echo "=> The building environment is ready."

build: $(VENV_USE) $(docs)
	@echo "=> Building HTML format..."
	$(BUILD) slides
	@echo "=> Done"
