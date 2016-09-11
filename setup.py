from setuptools import setup, find_packages
import os

"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""
import os
import sys
from setuptools import setup, find_packages

IS_PY24 = sys.version_info < (2, 7,)

install_requires = [
    'setuptools',
    ]
if not IS_PY24:
    # Only list lxml as a dependency when outside the legacy context,
    # which is one that isn't running python >= 2.7.
    install_requires.append('lxml')

version = '1.2'

setup(name='rhaptos.cnxmlutils',
      version=version,
      description="",
      long_description=open("README.txt").read() + "\n" +
                       open(os.path.join("docs", "HISTORY.txt")).read(),
      # Get more strings from
      # http://pypi.python.org/pypi?:action=list_classifiers
      classifiers=[
        "Programming Language :: Python",
        ],
      keywords='',
      author='Rhaptos Developers',
      author_email='rhaptos@rhaptos.org',
      url='http://rhaptos.org',
      license='GPL',
      packages=find_packages(exclude=['ez_setup']),
      namespace_packages=['rhaptos'],
      include_package_data=True,
      zip_safe=False,
      test_suite='rhaptos.cnxmlutils.tests',
      install_requires=install_requires,
      entry_points="""\
      [console_scripts]
      cnxml2html = rhaptos.cnxmlutils.xml2xhtml:main
      """,

      )
