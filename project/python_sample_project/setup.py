from setuptools import setup, find_packages

with open("README.md", "r") as readme:
    long_description = readme.read()

setup(
    name='pisample',
    version="0.1",
    url='',
    license='Apache 2.0',
    author='Michael Bouzinier',
    author_email='mbouzinier@g.harvard.edu',
    description='Sample Python project for CWL-Airflow',
    long_description = long_description,
    long_description_content_type = "text/markdown",
    py_modules = ['pi'],
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: Harvard University :: Development",
        "Operating System :: OS Independent"]
)
