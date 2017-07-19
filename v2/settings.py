import os
import yaml

DICT = None

if DICT is None:
	fileName = os.path.join(os.path.dirname(__file__), 'settings.yaml')
	f = open(fileName)
	DICT = yaml.safe_load(f)
	f.close()
