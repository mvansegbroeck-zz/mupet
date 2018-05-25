% gaussfit
function [sigma, mu] = gaussfit( x, y, handles, sigma0, mu0 )

    % Maximum number of iterations
    Nmax = 5;

    % delete peaks in probability density function
    y=smooth(y,handles.psd_smoothing_window_freq);

    if( length( x ) ~= length( y ))
        fprintf( 'x and y should be of equal length\n\r' );
        exit;
    end

    n = length( x );
    x = reshape( x, n, 1 );
    y = reshape( y, n, 1 );

    %sort according to x
    X = [x,y];
    X = sortrows( X );
    x = X(:,1);
    y = X(:,2);

    %Checking if the data is normalized
    dx = diff( x );
    dy = 0.5*(y(1:length(y)-1) + y(2:length(y)));
    s = sum( dx .* dy );
    if( s > 1.5 || s < 0.5 )
        %fprintf( 'Data is not normalized! The pdf sums to: %f. Normalizing...\n\r', s );
        y = y ./ s;
    end

    X = zeros( n, 3 );
    X(:,1) = 1;
    X(:,2) = x;
    X(:,3) = (x.*x);


    % try to estimate mean mu from the location of the maximum
    [ymax,index]=max(y);
    mu = x(index);

    % estimate sigma
    sigma = 1/(sqrt(2*pi)*ymax);

    if( nargin == 4 )
        sigma = sigma0;
    end

    if( nargin == 5 )
        mu = mu0;
    end

    %xp = linspace( min(x), max(x) );

    % iterations
    for i=1:Nmax
    %    yp = 1/(sqrt(2*pi)*sigma) * exp( -(xp - mu).^2 / (2*sigma^2));
    %    plot( x, y, 'o', xp, yp, '-' );

        dfdsigma = -1/(sqrt(2*pi)*sigma^2)*exp(-((x-mu).^2) / (2*sigma^2));
        dfdsigma = dfdsigma + 1/(sqrt(2*pi)*sigma).*exp(-((x-mu).^2) / (2*sigma^2)).*((x-mu).^2/sigma^3);

        dfdmu = 1/(sqrt(2*pi)*sigma)*exp(-((x-mu).^2)/(2*sigma^2)).*(x-mu)/(sigma^2);

        F = [ dfdsigma dfdmu ];
        a0 = [sigma;mu];
        f0 = 1/(sqrt(2*pi)*sigma).*exp( -(x-mu).^2 /(2*sigma^2));
        a = (F'*F)^(-1)*F'*(y-f0) + a0;
        sigma = a(1);
        mu = a(2);

        if( sigma < 0 )
            sigma = abs( sigma );
            fprintf( 'Instability detected! Rerun with initial values sigma0 and mu0! \n\r' );
            fprintf( 'Check if your data is properly scaled! p.d.f should approx. sum up to \n\r' );
            %exit;
        end
    end

end