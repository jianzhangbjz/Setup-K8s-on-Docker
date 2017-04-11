#!/bin/bash

set -e # exit on first error

#---------------------------------------------
# This script will gather the nvidia libary files. 
# It is used to mount nvidia driver volume for support GPU in a container.
#---------------------------------------------

#---------------------------------------------
# Note: needed Docker and NVIDIA driver installed.
#---------------------------------------------

if [ $# != 1 ]
then
	exit 0
fi

baseDir=$1

if [ ! -e ${baseDir} ]
then
	mkdir -p ${baseDir}
fi

date=`date`
driverVersion=`nvidia-smi | grep Driver | awk '{print $3}'`
if [ -z $driverVersion ]
then
	echo "SKIP"
	exit 0
fi

binDir="${baseDir}/bin"
libDir="${baseDir}/lib"
lib64Dir="${baseDir}/lib64"

if [ ! -d ${binDir} ]; then
	mkdir $binDir
fi

if [ ! -d ${libDir} ]; then
	mkdir $libDir
fi

if [ ! -d ${lib64Dir} ]; then
	mkdir $lib64Dir
fi

function collectBinary () {
	binaryArray=(
    #"nvidia-modprobe"       # Kernel module loader
    #"nvidia-settings"       # X server settings
    #"nvidia-xconfig"        # X xorg.conf editor
    "nvidia-cuda-mps-control" # Multi process service CLI
    "nvidia-cuda-mps-server"  # Multi process service server
    "nvidia-debugdump"        # GPU coredump utility
    "nvidia-persistenced"     # Persistence mode utility
    "nvidia-smi"              # System management interface
   	)
	for loop in ${binaryArray[@]}
	do
		location=`which ${loop}`
		destFile="${binDir}/${loop}"
		if [ ! -e ${destFile} ]; then
			cp ${location} ${destFile}
		fi
	done
}

function collectLibrary () {
	originPath=`echo $(pwd)`
	libraryArray=(

    # ------- X11 -------

    #"libnvidia-cfg.so"  # GPU configuration (used by nvidia-xconfig)
    #"libnvidia-gtk2.so" # GTK2 (used by nvidia-settings)
    #"libnvidia-gtk3.so" # GTK3 (used by nvidia-settings)
    #"libnvidia-wfb.so"  # Wrapped software rendering module for X server
    #"libglx.so"         # GLX extension module for X server

    # ----- Compute -----

    "libnvidia-ml.so"              # Management library
    "libcuda.so"                   # CUDA driver library
    "libnvidia-ptxjitcompiler.so"  # PTX-SASS JIT compiler (used by libcuda)
    "libnvidia-fatbinaryloader.so" # fatbin loader (used by libcuda)
    "libnvidia-opencl.so"          # NVIDIA OpenCL ICD
    "libnvidia-compiler.so"        # NVVM-PTX compiler for OpenCL (used by libnvidia-opencl)
    #"libOpenCL.so"               # OpenCL ICD loader

    # ------ Video ------

    "libvdpau_nvidia.so"  # NVIDIA VDPAU ICD
    "libnvidia-encode.so" # Video encoder
    "libnvcuvid.so"       # Video decoder
    "libnvidia-fbc.so"    # Framebuffer capture
    "libnvidia-ifr.so"    # OpenGL framebuffer capture

    # ----- Graphic -----

    # XXX In an ideal world we would only mount nvidia_* vendor specific libraries and
    # install ICD loaders inside the container. However for backward compatibility reason
    # we need to mount everything. This will hopefully change once GLVND is well established.

    "libGL.so"         # OpenGL/GLX legacy _or_ compatibility wrapper (GLVND)
    "libGLX.so"        # GLX ICD loader (GLVND)
    "libOpenGL.so"     # OpenGL ICD loader (GLVND)
    "libGLESv1_CM.so"  # OpenGL ES v1 common profile legacy _or_ ICD loader (GLVND)
    "libGLESv2.so"     # OpenGL ES v2 legacy _or_ ICD loader (GLVND)
    "libEGL.so"        # EGL ICD loader
    "libGLdispatch.so" # OpenGL dispatch (GLVND) (used by libOpenGL libEGL and libGLES*)

    "libGLX_nvidia.so"         # OpenGL/GLX ICD (GLVND)
    "libEGL_nvidia.so"         # EGL ICD (GLVND)
    "libGLESv2_nvidia.so"      # OpenGL ES v2 ICD (GLVND)
    "libGLESv1_CM_nvidia.so"   # OpenGL ES v1 common profile ICD (GLVND)
    "libnvidia-eglcore.so"     # EGL core (used by libGLES* or libGLES*_nvidia and libEGL_nvidia)
    "libnvidia-egl-wayland.so" # EGL wayland extensions (used by libEGL_nvidia)
    "libnvidia-glcore.so"      # OpenGL core (used by libGL or libGLX_nvidia)
    "libnvidia-tls.so"         # Thread local storage (used by libGL or libGLX_nvidia)
    "libnvidia-glsi.so"        # OpenGL system interaction (used by libEGL_nvidia)
	
	)
	for each in ${libraryArray[@]}
	do
		for bit in 64 32 # 64bit and 32bit
		do 
			lib=`ldconfig -p | grep ${each}  | grep $bit | awk '{print $NF}' | xargs`
			for one in $lib #lookup the symbol links
			do
				if [ -n "$one" ]
				then
					if [ $bit == 64 ]
					then
						destDir=$lib64Dir
					else
						destDir=$libDir
					fi
					if [ -L $one ]
					then
						pDir=`echo $(dirname $one)`
						fileName=`echo $(basename $one)`
						currentFile=$one
						count=1
						libFlag=0
						while [ $count -le 5 ]
						do
							count=`expr $count + 1`
							symbolName=`echo $(readlink $currentFile)`
							if [ -z $symbolName ]
							then
								libFlag=1
								break
							fi
                       		if [ ! -f ${symbolName} ] #If not a normal file, structure the source file.
                       		then
								dir=`echo $(dirname $currentFile)`
                       			currentFile="$dir/$symbolName"
							fi
						done
						if [ $libFlag -eq 1 ]
						then
							cp ${currentFile} ${destDir}
							if [ $? == 0 ]
							then
								baseName=`echo $(basename ${currentFile})`
							fi
						fi

						cd ${destDir}
						ln -fs $baseName $fileName	
						cd ${originPath}
						
					else
						cp $one $destDir #not symbol file, copy directly.
					fi
				fi
			done
		done
	done
}

collectBinary
collectLibrary
echo "OK"
