function [R,epsilon] = computeRecurrence( D,radius,verbose )
% [R,epsilon] = computeRecurrence( D, (,radius), (,verbose) );
% 
% computes the recurrence matrix R from the distance matrix D
%
% normalizes the distance matrix "D" then thresholds by 
% "radius" (between 0 and 1) to get 1's or 0's corresponding to distances
% smaller or larger than radius. If "radius" is empty, a search will be 
% employed to get a recurrence matrix with ~ 5% density.

% check inputs
if nargin < 2 || isempty(radius)
    radius = nan;
end
if nargin < 3 || isempty(verbose)
    verbose = 0;
end
if radius <= 0 || radius >= 1
    error('Radius must be within (0, 1), non-inclusive');
end

N = size(D,1); 
maxdensity = 0.051; % maximum is 5.1 % RR
mindensity = 0.049; % minimum is 4.9 % RR
epsilon = nan;
indices = reshape( 1:N*N,N,N ); % for extracting diagonal elements of D

% clean up R
for j = 1:3 % consecutive time points
    D(diag( indices,j )) = 1e6;
    D(diag( indices,-j )) = 1e6;
end

% search for best epsilon if not provided
if isnan(radius)
    if verbose == 1
        fprintf('\nEstimating recurrence epsilon...\n')
    end
    guess = 0.5;

    % begin search
    while isnan(epsilon)
        count = 0;

        % print to screen
        if mod(count,10) == 0 && verbose == 1
            fprintf(' . ');
        end

        % compare density with previous density
        if exist('density','var')
            density2 = density; % to compare pre-density
            clear R denstiy
        else
            density2 = 0;
        end

        % threshold D for recurrence matrix, get density
        R = D <= guess; 
        density = sum(sum(R)) / N^2; % density of recurrence matrix

        if density > maxdensity
            guess = guess - .01; 
        elseif density < mindensity && density2 < mindensity 
            guess = guess + .01;
        elseif density < mindensity && density2 > maxdensity
            % here the best guess is between density2 and density...
            % take the mean value between epsilon i and i-1
            epsilon = mean([guess,guess+.01]);
            break
        else
            epsilon = guess;
            break
        end
        count = count+1;
    end
    
    if verbose == 1
        fprintf('\nepsilon is: %d\n',epsilon);
    end
    
else % if radius provided
    R = D <= radius;
end

end