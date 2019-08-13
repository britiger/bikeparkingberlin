#!/usr/bin/env python3

import os
import sys
from dotenv.main import load_dotenv

this_dir = os.path.dirname(__file__)
sys.path.insert(0, this_dir)

env_path = os.path.abspath(this_dir + '/../config')
load_dotenv(dotenv_path=env_path, override=True)

from app import create_app
application = create_app()