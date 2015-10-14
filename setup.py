from setuptools import setup, find_packages
import os

"""
Copyright (C) 2013 Rice University

This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
See LICENSE.txt for details.
"""

from setuptools import setup, find_packages
import os

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
      install_requires=[
          'setuptools',
      #    'lxml',
          #'argparse',
          # -*- Extra requirements: -*-
      ],
      entry_points="""
      # -*- Entry points: -*-
      """,
      )
