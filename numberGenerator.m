% Bu fonksiyon panele random olarak yerle�tirilecek eleman�n
% koordinatlar�n� d�ner.
function [X , Y] =  numberGenerator(allData)

X = 0;
Y = 0;

% �retilecek random say�n�n s�n�rlar� al�nd�.
randXLimit = pref.panelWeight;
randYLimit = pref.panelHeight;

while(true)
    
    % koordinat duzlemi icin rastgele sayi ataniyor.
    tmpX = randi([1 randXLimit],1,1);
    tmpY = randi([1 randYLimit],1,1);

    isExist = isExistOnPanel(tmpX , tmpY , allData);
    if isExist ~= true
       break;
    end
end

if isExist ~= true
    
    X = tmpX;
    Y = tmpY;
    
end


function isExist = isExistOnPanel( X , Y , allData)
% Foksiyon robotlar, cisimler ve hedeflerde b�yle bir kordinat�n olup
% olmad���na bak�yor.

tmp = allData.robotObj;
isSame = false;
for i=1:length(tmp)
    s = tmp(i)
    if ( round(s.x) == X ) && ( round(s.y) == Y )
        isSame = true;
        break;
    end
end

tmp = allData.cisimObj;
if isSame ~= true
    for i=1:length(tmp)
        s = tmp(i)
        if ( round(s.x) == X ) && ( round(s.y) == Y )
            isSame = true;
            break;
        end
    end
end
tmp = allData.goalObj;
if isSame ~= true
    
    for i=1:length(tmp)
        s = tmp(i)
        if ( round(s.x) == X ) && ( round(s.y) == Y )
            isSame = true;
            break;
        end
    end
end

isExist = isSame;
