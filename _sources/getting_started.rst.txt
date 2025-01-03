===============
Getting Started
===============

Clone gupje somewhere on your system:

.. code-block:: bash

    git clone --recursive https://git.herreweb.nl/EljakimHerrewijnen/Gupje


Cross compiler
--------------
You will also need a cross compiler for the target you are going to debug. 
For this we use the ``Android NDK``. Download one from the `official website <https://developer.android.com/ndk>`_ and extract it somewhere on your system.

.. code-block:: bash

    wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip
    unzip android-ndk-r21e-linux-x86_64.zip

Now set the ``ANDROID_NDK_ROOT`` environment variable:

.. code-block:: bash

    export ANDROID_NDK_ROOT=/path/to/android-ndk-r21e

Target Setup
------------
Gupje is compiled against a specific target. This means that you need to download a target or build one. 
The Raspberry pi 4 is a good example target to start with. Please see the `Raspberry Pi 4 target <targets/rpi4.html>`_ for more information.

