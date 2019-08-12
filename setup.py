"""
Copyright (C) 2013-2017 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).
See LICENSE.txt for details.
"""
import os
import sys
from setuptools import setup, find_packages

import versioneer


IS_PY24 = sys.version_info < (2, 7,)

install_requires = [
    'setuptools',
    ]
if not IS_PY24:
    # Only list lxml as a dependency when outside the legacy context,
    # which is one that isn't running python >= 2.7.
    if sys.version_info == (2, 7)  or sys.version_info >= (3, 5):
        install_requires.append('lxml')
    else:
        # lxml 4.4.1 requires python 2.7, 3.5 or later.
        install_requires.append('lxml>=4, <4.4')

version = versioneer.get_version()

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
      author='OpenStax/Connexions Developers',
      author_email='info@cnx.org',
      url='https://github.com/Connexions/rhaptos.cnxmlutils',
      license='GPL',
      packages=find_packages(exclude=['ez_setup']),
      namespace_packages=['rhaptos'],
      include_package_data=True,
      zip_safe=False,
      cmdclass=versioneer.get_cmdclass(),
      test_suite='rhaptos.cnxmlutils.tests',
      install_requires=install_requires,
      )
