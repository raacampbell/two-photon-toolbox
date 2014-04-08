if (exist('register3Symmetric.ptx','file') ~= 2)
   if (ispc)
       [status, result] = system('"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" & nvcc -ptx register3Symmetric.cu','-echo');
   else
       [status, result] = system('nvcc -ptx register3Symmetric.cu','-echo');
   end
end

if (exist('register3.ptx','file') ~= 2)
   if (ispc)
       [status, result] = system('"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" & nvcc -ptx register3.cu','-echo');
   else
       [status, result] = system('nvcc -ptx register3.cu','-echo');
   end
end

if (exist('register2Symmetric.ptx','file') ~= 2)
   if (ispc)
       [status, result] = system('"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" & nvcc -ptx register2Symmetric.cu','-echo');
   else
       [status, result] = system('nvcc -ptx register2Symmetric.cu','-echo');
   end
end

if (exist('register2.ptx','file') ~= 2)
   if (ispc)
       [status, result] = system('"C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" & nvcc -ptx register2.cu','-echo');
   else
       [status, result] = system('nvcc -ptx register2.cu','-echo');
   end
end