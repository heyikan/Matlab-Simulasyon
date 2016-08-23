% Fonksiyon iki nokta aras�ndaki e�im ve uzakl�k de�erlerini bulur ve bunu
% bile�enlerine ay�r�r.

function [gravX  , gravY] = calculateGravValuesWhenGrouped(X)
% ilk de�erler al�nd�.
f = X(1,:);
% ikinci de�erler al�nd�.
s = X(2,:);

% index(1) X koordinat�
% index(2) Y koordinat�
% index(3) K�tle de�erleri

% Hesaplamalar yapiliyor.

gravForce = 0;

distance = pdist([f(1) , f(2) ; s(1) , s(2) ],'euclidean')


if distance > pref.gravDistanceLimit
% 1 Kutle cekim Formulu uygulaniyor. (M1 * M2 ) / d^2
gravForce = ( f(3) * s(3) )/(distance.^2);

else
    gravForce = 0.3*( f(3) * s(3) )/(distance.^2);
end


% distance = pdist([f(1) , f(2) ; s(1) , s(2) ],'euclidean')
% 
% gravForce = ( f(3) * s(3) )/(distance.^2);

% �ki Nokta Arasindaki Egim Hesaplaniyor.
slope = calculateSlope(X);
area = determinePointArea(X);

if area == 1 factorX = 1;factorY = 1; end
if area == 2 factorX = -1; factorY = 1; end
if area == 3 factorX = -1; factorY = -1; end
if area == 4 factorX = 1; factorY = -1; end

gravX = (gravForce * cosd(slope) * factorX);
gravY = (gravForce * sind(slope) * factorY);

    