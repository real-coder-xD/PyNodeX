from setuptools import setup
from Cython.Build import cythonize

setup(
    name="fast_utils",
    ext_modules=cythonize(
        "library/cfast.pyx",
        compiler_directives={
            "initializedcheck": False,
            "language_level": "3",
            "boundscheck": False,
            "wraparound": True,
            "nonecheck": False,
            "cdivision": True,
        },
    ),
    zip_safe=False,
)
