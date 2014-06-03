function doParallel=tryParallel(testParallel)
% try/catch to see if parallel execution is functional
%
% Purpose
% Attempt parallel execution and fail gracefully if it doesn't work. Return 
% state (failed/worked) as a bool. 
%
% Inputs
% testParallel - optional. 1 by default. if == 0 the function just returns
%
% Example
% P=tryParallel
% P=tryParallel(0); %function doesn't even execute 
%
% Rob Campbell - 2014


if nargin==0
	testParallel=1;
end

if ~testParallel
	doParallel=0;
	return
end


try 
	parfor ii=1:2, end
	doParallel=1;
catch
	doParallel=0;
	warning('Parallel execution failed');
end