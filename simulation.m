function varargout = simulation(varargin)



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulation_OpeningFcn, ...
                   'gui_OutputFcn',  @simulation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function simulation_OpeningFcn(hObject, eventdata, handles, varargin)


handles.output = hObject;

% koordinat duzlemi ayarlandi
xlim manual;
ylim manual;


lx = pref.panelWeight;
ly = pref.panelHeight;

xlim([0 lx]);
ylim([0 ly]);

axis([0,lx,0,ly]);
 axis equal;


% Robot Tablosu ayarlandi
t = handles.uitable1;
set(t , 'ColumnName' , {'Robot' , 'X' , 'Y'});

% Cisim Tablosu ayarlandi
t2 = handles.uitable2;
set(t2 , 'ColumnName' , {'Obstacle' , 'X' , 'Y'});

% Hedef Tablosu ayarlandi
t3 = handles.uitable3;
set(t3 , 'ColumnName' , {'Goal' , 'X' , 'Y'});

% Grup Sayisi initial olarak 0 atandi
setGroupCount(0);
setIsPopupClicked(false);

guidata(hObject, handles);


% Options nesnesi i�in global de�i�kene atama yap�l�yor.
opt = options;
opt.arrowStatus = true;
opt.circleVisible = false;
opt.robotPath = false;
setOptObj(opt);

% Butonlara �con Ekleniyor
X = imread('icons\robot.jpg');
set(handles.addRobot,'CData',X);

X = imread('icons\cisim.jpg');
set(handles.addCisim,'CData',X);

X = imread('icons\hedef.jpg');
set(handles.addGoal,'CData',X);

% X = imread('icons\hand.jpg');
% set(handles.addManual,'CData',X);

X = imread('icons\play.jpg');
set(handles.animation,'CData',X);

X = imread('icons\magnet.jpg');
set(handles.kutleCekim,'CData',X);

X = imread('icons\flag.jpg');
set(handles.liderAta,'CData',X);

X = imread('icons\cop.jpg');
set(handles.robotSil,'CData',X);

X = imread('icons\print.jpg');
set(handles.printInfos,'CData',X);


% X = imread('icons\save.jpg');
% set(handles.saveScenario,'CData',X);

% Paneldeki axe adresi al�yor.
% gca : get current axes
panel = gcf;
position = get(gca , 'Position');
% Event Listener: on mouse hover eventi ekleniyor
set(panel , 'WindowButtonMotionFcn' , @coordinate_callback)
% Event Listener: is mouse clicked eventi ekleniyor
set(panel , 'WindowButtonDownFcn' , {@ClicktoAdd_callback,handles})

function ClicktoAdd_callback (src,callbackdata,handles)

% E�er herhangi bir popup ekran� a��k de�ilse callback �al��t�r.
if getIsPopupClicked == false

    % Axe nesnesinde  position de�erini al.
    % Position [left bottom width height]
    position = get(gca , 'Position');
    
    pLeft = position(1);
    pBottom = position(2);
    pWidth = position(3);
    pHeight = position(4);
    
    
    % Paneli al.
    seltype = get(src,'CurrentPoint');
    left = seltype(1);
    bottom = seltype(2);
    
    if left > pLeft && left < pLeft + pWidth && bottom > pBottom && bottom < pBottom + pHeight
        
        posCurr = get(gca , 'CurrentPoint');
        X = posCurr(1);
        Y = posCurr(3);
        %      type = choosedialog('Eklenecek Eleman:');
        
        avail = isAvailOnPanel(X,Y);
        
        if avail == true
 
            setIsPopupClicked( true );
            hold on
            type = gui_pop('Eklenecek Eleman');
            hold off
            setIsPopupClicked( false );
            
            
            addElementToPanel(X , Y ,type , handles);
        end
    end
end

function coordinate_callback (src,callbackdata)

% E�er herhangi bir popup ekran� a��k de�ilse callback �al��t�r.
if getIsPopupClicked == false
    
    % Axe nesnesinde  position de�erini al.
    % Position [left bottom width height]
    position = get(gca , 'Position');
    
    pLeft = position(1);
    pBottom = position(2);
    pWidth = position(3);
    pHeight = position(4);
    
    
    % Paneli al.
    seltype = get(src,'CurrentPoint');
    left = seltype(1);
    bottom = seltype(2);
    
    % Robotlar�n �zerine Geldi�inde Bilgisi G�z�ks�n.
    
     textObj = findobj('Tag' , 'tipText');
    
    
    if left > pLeft && left < pLeft + pWidth && bottom > pBottom && bottom < pBottom + pHeight
        
        posCurr = get(gca , 'CurrentPoint');
        
        X = posCurr(1);
        Y = posCurr(3);
        
        avail = isAvailOnPanel(X,Y);
        
        if avail == true
            
            
            set(textObj, 'Visible' , 'off');
            
            
            s1 = num2str( posCurr(1) );
            s2 = num2str(posCurr(3) );
            res = strcat(s1,{' x '},s2);
            
            set(findobj('Tag' , 'coordinate') , 'String' , res );
            
            set(gcf,'Pointer','fullcross');
            
            
                
        
    
        else
            set(gcf,'Pointer','arrow');
            
            textObj = findobj('Tag' , 'tipText');
            
            
            set(textObj, 'Visible' , 'on');
%             set(textObj, 'Visible' , 'on');
            mainPos = get(gcf , 'CurrentPoint');
            
            
            % Mouse ile panelde elemanlar�n �zerine gelindi�inde textinput
            % a bas�lacak de�erler.
            
            % Pozisyon Ayarland�.
            set(textObj,  'Position' , [mainPos(1) mainPos(2) 25 9]);
            
            % Bas�lacak Sting Haz�rlan�yor.

            [id , type] = getMeIDUsingCoordinate(X , Y);
            
%             tmp;
    
         printedValue='';
            
            if strcmp(type , 'Robot')
                tmp = getRobotObj;
                s = tmp(id);
                

                printedValue = sprintf('gravSlope: %s\ngravLength: %s\ngroupID: %s\nisLeader: %s\n' , num2str(s.gravSlope) ,num2str(s.gravLength) , num2str(s.groupID) ,num2str(s.isLeader) );

            end
            
            if strcmp(type , 'Cisim')
                tmp = getCisimObj;
            end
            
            if strcmp(type , 'Hedef')
                tmp = getHedefObj;
            end
            
            
            
%             tmp(id)
            
            set(textObj, 'string' , printedValue);
        end
        
 
        
    else
        set(findobj('Tag' , 'coordinate') , 'String' , '' );
        set(gcf,'Pointer','arrow');
    
    end

end

function varargout = simulation_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
   
% Robotlarin Adreslerini tutan global degisken.
function setRobotObj(val)
global robotObj
robotObj = val;

function r = getRobotObj
global robotObj
r = robotObj;

% Nesnelerin Adreslerini tutan global degisken.
function setCisimObj(val)
global cisimObj
cisimObj = val;

function r = getCisimObj
global cisimObj
r = cisimObj;

% Hedeflerin Adreslerini tutan global de�i�ken
function setGoalObj(val)
global goalObj
goalObj = val;

function r = getGoalObj
global goalObj
r = goalObj;

% A��rl�k merkezlerinin Adreslerini tutan global de�i�ken
function setMassObj(val)
global massObj
massObj = val;

function r = getMassObj
global massObj
r = massObj;

% Gruplara Id atamasi icin kullanilan global degisken
function setGroupCount(val)
global groupCount
groupCount = val;

function r = getGroupCount
global groupCount
r = groupCount;

% Se�enekler i�in �retilen de�i�ken
function setOptObj(val)
global Opt
Opt = val;

function r = getOptObj
global Opt
r = Opt;


% Herhangi bir popup ekran� a��lmas� durumunda callback fonksiyonlar�n�
% durdumaya yarayan boolean de�i�ken.
function setIsPopupClicked(val)
global clicked
clicked = val;

function r = getIsPopupClicked
global clicked
r = clicked;



function addRobot_Callback(hObject, eventdata, handles)
hold on;

% Panele yerle�tirilmek �zere rastgele bir say� �retiliyor.
[X , Y] = numberGenerator;

%robot panele ekleniyor
addElementToPanel(X , Y , 'Robot' , handles);

hold off;

function addCisim_Callback(hObject, eventdata, handles)
hold on;

% Panele yerle�tirilmek �zere rastgele bir say� �retiliyor.
[X , Y] = numberGenerator;

%robot panele ekleniyor
addElementToPanel(X , Y , 'Cisim' , handles);

hold off;

function addGoal_Callback(hObject, eventdata, handles)
hold on;

% Panele yerle�tirilmek �zere rastgele bir say� �retiliyor.
[X , Y] = numberGenerator;

%robot panele ekleniyor
addElementToPanel(X , Y , 'Hedef' , handles);

hold off;

function addElementToPanel(X ,Y , type ,handles)
    
    global s;

    if strcmp(type , 'Robot')
        %robot ekleniyor
        s = robotInfo; % Yeni nesne olusturuldu
        s.id = length(getRobotObj) + 1;      % id Atandi
        
        s.mass = pref.robotMass;             % Kutle Atandi
        s.groupID = 0;                       % Group ID 0 Atandi
        s.isLeader = 0;                      % Liderlik durumu false ayarlandi.
        s.centerOfMassValue = pref.groupMemberMass;             % Grupland��� zaman kullan�cak k�tle de�eri  atand�
        s.groupedMass = 0;                   % Robotlar hen�z gruplanmad�klar�ndan 
                                             % itme i�in kullan�lacak k�tle de�eri 0 atand�.
        
        
        % Robot Tablosu Se�ildi
        tableVal = handles.uitable1;
        
    end
    if  strcmp(type , 'Cisim')
        %cisim ekleniyor
        
        s = cisimInfo;                       % Yeni nesne olusturuldu
        s.id = length(getCisimObj) + 1;      % id Atandi
        s.mass = pref.cisimMass;             % Kutle Atandi
        
        % Cisim Tablosu Se�ildi
        tableVal = handles.uitable2;
        
    end
    if strcmp(type , 'Hedef')
        % Hedef ekleniyor
        s = hedefInfo;                       % Yeni hedef olusturuldu
        s.id = length(getGoalObj) + 1;      % id Atandi
        s.mass = pref.hedefMass;             % Kutle Atandi
        
        
        % Hedef Tablosu Se�ildi
        tableVal = handles.uitable3;
        
    end
    
    if strcmp(type , 'Null')
        return;
    end
    
    s.x = X;                             % x koorinati Atandi
    s.y = Y;                             % y koorinati Atandi
    
    tmp = {s.id ,s.x, s.y};              % Veriler tabloya aktarilmak uzere cell array e atandi
    
    
    printToTable(tableVal , tmp); % Veriler tabloya bas�ld�.
    
    
    if strcmp(type , 'Robot')
        
        s.color = randomColor;
        s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi
        
    end
    if  strcmp(type , 'Cisim')
        s.color = randomColor;
        s.rectangleObj = circles(X,Y,1,'vertices',4,'rot',45);      % Cisim olusturuldu ve adresi nesneye atandi
        
    end
    if  strcmp(type , 'Hedef')
        
        s.rectangleObj = circles(X,Y,1,'vertices',5,'rot',0, 'facecolor' , 'red');      % Cisim olusturuldu ve adresi nesneye atandi
        
        
    end
    
    %robot ID'si daire icine yazi olarak ekleniyor.
    if s.id > 9
        s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
    else
        s.textObj = text(X,Y,int2str(s.id));
    end
    
    set(s.textObj , 'FontSize',12);
    set(s.textObj , 'FontWeight','bold');
    
    
    
    if  strcmp(type , 'Robot')
        setRobotObj([getRobotObj s]);
    end
    if strcmp(type , 'Cisim')
        setCisimObj([getCisimObj s]);
        
    end
    if  strcmp(type , 'Hedef')
        
        
        setGoalObj([getGoalObj s]);
        
        
    end
    
% Foksiyon Eleman� Panleden ve ait oldu�u nesneden siler.    
function eraseElementToPanel(type , handles)

global s;

if strcmp(type , 'Robot')
    
    % Robot Siliniyor.
    tmp = getRobotObj;
    
    %arrow(Varsa Sil)
    eraseArrows;
    
    for i=1:length(getRobotObj);
        
        s = tmp(i);
        
        rectObj  = s.circleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
    
    %tabloyu da bosalt
    table = handles.uitable1;
    set(table , 'Data' ,{} );
    
    % array'i bosalt
    setRobotObj([]);
    
    % GrupCount 0 ata
    setGroupCount(0);
    
end

if strcmp(type , 'Cisim')
    
        % Cisim Siliniyor.
    tmp = getCisimObj;
    
    for i=1:length(tmp);
        
        s = tmp(i);
        
        rectObj  = s.rectangleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
    
    %tabloyu da bosalt
    table = handles.uitable2;
    set(table , 'Data' ,{} );
    
    % array'i bosalt
    setCisimObj([]);
     
    
end

if strcmp(type , 'Hedef')
    
    
    % Hedef Siliniyor.
    tmp = getGoalObj;
    
    for i=1:length(tmp);
        
        s = tmp(i);
        
        rectObj  = s.rectangleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
    
    %tabloyu da bosalt
    table = handles.uitable3;
    set(table , 'Data' ,{} );
    
    % array'i bosalt
    setGoalObj([]);
    
    
end

% Bu fonksiyon panele random olarak yerle�tirilecek eleman�n
% koordinatlar�n� d�ner.
function [X , Y] =  numberGenerator

X = 0;
Y = 0;

% �retilecek random say�n�n s�n�rlar� al�nd�.
randXLimit = pref.panelWeight;
randYLimit = pref.panelHeight;

while(true)
    
    % koordinat duzlemi icin rastgele sayi ataniyor.
    tmpX = randi([1 randXLimit],1,1);
    tmpY = randi([1 randYLimit],1,1);

    isAvail = isAvailOnPanel(tmpX , tmpY);
    
    if isAvail == true
       break;
    end
    
end

if isAvail == true
    
    X = tmpX;
    Y = tmpY;
    
end

function avail = isAvailOnPanel( X , Y )

% Foksiyon robotlar, cisimler ve hedeflerde b�yle bir kordinat�n olup
% olmad���na bak�yor.
% E�er Se�ilen koordinat gruplanm�� robotlar�n bulundu�u bir alana denk
% gelmi�se de�er false d�necek.

tmp = getRobotObj;
isAvail = true;

for i=1:length(tmp)
    s = tmp(i);
    
    if s.groupID ~= 0 % Bir gruba ba�l�ysa. 
    % Bu grup �evresinde random atama yapamayacak.
    
    % Grubun A��rl�k merkezi bulunacak ve pref.circleRadius alan�n�n
    % i�indeyse random atama yap�lmayacak.
    
    totalX = 0;
    totalY = 0;
    
    arr = getMeGroupRobots(s.groupID);
    
    for j=1:length(arr)
        totalX = totalX + tmp(arr(j)).x;
        totalY = totalY + tmp(arr(j)).y;
    end
    
    massX = round ( (totalX / pref.groupCount) * 1e2 ) / 1e2;
    massY = round ( (totalY / pref.groupCount) * 1e2 ) / 1e2;
    
    
    
    % massX ve massY koordinatlar�n�n pref.groupRadius ile belirlenmi� alan
    % i�erisine random ekleme yap�lmas�n� engellemek i�in fonksiyon
    % �a��r�l�yor.
    
    % arrX [mevcutX , mevcuY ; eklenmek�stenenX , eklenmek�stenenY]
    arrX = [massX , massY ; X , Y];
    
    isAvail = calculateBordersForAvail(arrX ,pref.groupRadius );
    
    if isAvail == false
        break;
    end
  
    end
    
    if s.groupID == 0 % Bir Gruba Ba�l� De�ilse:
        
        arrX = [s.x , s.y ; X , Y];
        
            isAvail = calculateBordersForAvail(arrX ,pref.robotRadius );

            if isAvail == false
                break;
            end
    end

end


tmp = getCisimObj;
if isAvail == true
    for i=1:length(tmp)
        s = tmp(i);
        
        arrX = [s.x , s.y ; X , Y];
        
        isAvail = calculateBordersForAvail(arrX ,pref.cisimRadius );

            if isAvail == false
                break;
            end
        
        
    end
end

tmp = getGoalObj;
if isAvail == true
    
    for i=1:length(tmp)
        s = tmp(i);
        
        arrX = [s.x , s.y ; X , Y];
        
        isAvail = calculateBordersForAvail(arrX ,pref.hedefRadius );

            if isAvail == false
                break;
            end
    end
end



avail = isAvail;




% E�er Se�ilen koordinat elemanlardan herhangi birinin bulundu�u 
% bir alana denk gelmi�se bu elemana ait id ve tip bilgileri d�necek
% gelmemi�se id 0 type 'null' d�necek.

function [id , type ]= getMeIDUsingCoordinate(X , Y)

id = 0;
type = 'null';



% Robotlar aran�yor.
tmp = getRobotObj;

for i=1:length(tmp)
    
    s = tmp(i);
    
    elemX = s.x;
    elemY = s.y;
    
    arrX = [elemX , elemY ; X , Y];
    
    isAvail = calculateBordersForAvail(arrX ,pref.robotRadius );
    
    % isAvail false d�nerse bu konumda bir robot var demektir. o robotun
    % id si ve type � g�nderilecek
    if isAvail == false
        id = s.id;
        type = 'Robot';
        break;
    end
    
    
end


% Cisimler Aran�yor.
tmp = getCisimObj;

for i=1:length(tmp)
    
    s = tmp(i);
    
    elemX = s.x;
    elemY = s.y;
    
    arr = [elemX , elemY ; X , Y];
    
    isAvail = calculateBordersForAvail(arrX ,pref.cisimRadius );
    
    % isAvail false d�nerse bu konumda bir robot var demektir. o robotun
    % id si ve type � g�nderilecek
    if isAvail == false
        id = s.id;
        type = 'Cisim';
        break;
    end
    
    
end

% Hedefler Aran�yor.
tmp = getGoalObj;

for i=1:length(tmp)
    
    s = tmp(i);
    
    elemX = s.x;
    elemY = s.y;
    
    arr = [elemX , elemY ; X , Y];
    
    isAvail = calculateBordersForAvail(arrX ,pref.hedefRadius );
    
    % isAvail false d�nerse bu konumda bir robot var demektir. o robotun
    % id si ve type � g�nderilecek
    if isAvail == false
        id = s.id;
        type = 'Hedef';
        break;
    end
    
    
end


% Fonksiyon paneldeki elemanlar�n yak�n �evrelerine atama yap�lmamas� i�in
% s�n�rlar� kontrol eder.
function available = calculateBordersForAvail(X , radius)


isAvail = false;

% ilk de�erler al�nd�.
f = X(1,:);
% ikinci de�erler al�nd�.
s = X(2,:);

% �st Limit
topLimitX = f(1) + radius;
% altLimit
downLimitX = f(1) - radius;

% �st Limit
topLimitY = f(2) + radius;
% altLimit
downLimitY = f(2) - radius;

X = s(1);
Y = s(2);


% X ve Y i�in sonu�lar.

% X i�in alan�n i�inde mi ?
if X > f(1) % mevcutX'den B�y�kse
    resX =  X - topLimitX;
end

if X <= f(1) % mevcutX'den K���kse
    resX = downLimitX - X;
end

% Y i�in alan�n i�inde mi ?
if Y > f(2) % mevcutY'den B�y�kse
    resY =  Y - topLimitY;
end

if Y <= f(2) % mevcutY'den K���kse
    resY = downLimitY - Y;
end


%     fprintf('eklenmek�stenenX: %3f - eklenmek�stenenY:%3f \n' , X , Y);
%     fprintf('mevcutX: %3f - mevcuY:%3f \n' , f(1) ,f(2));
%     fprintf('topLimitX: %3f - downLimitX:%3f \n' , topLimitX ,downLimitX);
%     fprintf('topLimitY: %3f - downLimitY:%3f \n' , topLimitY ,downLimitY);
%     fprintf('resX: %3f - resY:%3f \n' , resX ,resY);
    
if( resX <= 0 ) && ( resY <= 0 )
%         fprintf('eklenmek�stenenX: %3f - eklenmek�stenenY:%3f \n' , X , Y);
%     fprintf('mevcutX: %3f - mevcuY:%3f \n' , f(1) ,f(2));
%     fprintf('topLimitX: %3f - downLimitX:%3f \n' , topLimitX ,downLimitX);
%     fprintf('topLimitY: %3f - downLimitY:%3f \n' , topLimitY ,downLimitY);
%     fprintf('resX: %3f - resY:%3f \n' , resX ,resY);
%     disp('m�sait de�il');
    isAvail = false;
    
else
%             disp('m�sait');
    isAvail = true;
    
end

available = isAvail;


% Foksiyon verilen tabloya eklenen koordinat bilgilerini girer.
function printToTable(table , tmp)

tableArray = get(table , 'Data');
    if size(tableArray,2) == 2
        % Table bos: atama yapilacak
        tableArray = tmp;
    else
        % Table dolu: concatenation
        tableArray = [tableArray ; tmp ];
    end

set(table,'Data',tableArray);     % Tabloya veri Eklendi

function kutleCekim_Callback(hObject, eventdata, handles)
gravAlgorithm

function gravAlgorithm

% Panelde her robotun �ekim & itimi i�in oklar g�sterilsin mi ?
opt = getOptObj;

if opt.arrowStatus == true
% Oklar Guncelleneceginden ilk olarak tum oklar siliniyor.
eraseArrows;
end

% Her bir robot icin kutle cekim algoritmasi uygulaniyor.
for i = 1:length(getRobotObj)
    GravCalculationbyID(i);
end

% Fonksiyon verilen robot i�in �zerindeki t�m itim ve �ekim 
% kuvvetlerini toplayarak toplam k�tle �ekimini olu�turur.
function GravCalculationbyID(val)

totalGravX = 0.0;
totalGravY = 0.0;

%val'inci index deki robot se�ildi.
tmp = getRobotObj;
rObj = tmp(val);

fX = rObj.x;
fY = rObj.y;
fM = rObj.mass;
group = rObj.groupID;



% Robot E�er herhangi bir gruba ba�l� de�ilse:
% Bu durumda:
% (1): Di�er Robotlar�n �tme kuvvetleri
% (2): Cisimlerin itme kuvvetleri
% (3): hedefin itme kuvveti
% etki eder.

% Ortak olarak; t�m durumlarda cisimlerin bir itme kuvveti vard�r.
% Bu Robota Di�er cisimler taraf�ndan uygulanan 
% t�m itme kuvvetleri hesaplan�yor.

tmp = getCisimObj;
for j=1:length(getCisimObj)
    
    %s�radaki cisim se�ildi.
    currentObj  = tmp(j);
    
    sX = currentObj.x;
    sY = currentObj.y;
    sM = currentObj.mass;
    
    X = [fX , fY , fM ; sX , sY , sM ];
    
    % E�er B�t�n Cisimlerin Etkisi Sisteme Kat�l�rsa:
    % �oklu Cisim Eklendi�inde toplu bir itim kar��s�nda robot
    % Di�er Robotlara veya hedefe gidebilmek i�in yeterli kuvvete sahip
    % Olam�yor.
    
    % K�tle 0 oldu�unda itim de olmaz.
    if rObj.mass ~= pref.robotGroupedMass && isRangeLimitEnough(X)

        
        [gravX , gravY] = calculateGravValues(X);
        
        totalGravX = totalGravX + gravX;
        totalGravY = totalGravY + gravY;
        
     end
end

% ------------------------------ %

if group == 0 % Gruplanmam��sa
    
    % (1) : Di�er Robotlar�n �ekim kuvvetleri etki eder.
    % NOT: GRUPLANMAMI� ROBOTLARIN....
    tmp = getRobotObj;
    for j=1:length(getRobotObj)
        
        % s�radaki robot
        currentObj = tmp(j);
        
        if ( j~= val ) && ( isFullyGrouped(currentObj) == false )
            
            sX = currentObj.x;
            sY = currentObj.y;
            sM = currentObj.mass;
            
            X = [fX , fY , fM ; sX , sY , sM ];
            
            [gravX , gravY] = calculateGravValues(X);
            
            totalGravX = totalGravX + gravX;
            totalGravY = totalGravY + gravY;
        end
        
    end

    % (2) : Hedeflerin Gruplanmam�� Robotlar �zerinde itme kuvveti
    % olu�turacak
    tmp = getGoalObj;
    for j=1:length(tmp)
        
        % s�radaki cisim se�ildi.
        currentObj = tmp(j);
        
        sX = currentObj.x;
        sY = currentObj.y;
        sM = pref.hedefMassNotGrouped; % Hen�z Gruplanmam�� Robotlar i�in K�tle de�eri
        
        X = [fX , fY , fM ; sX , sY , sM ];
        
        

        if isRangeLimitEnough(X)
           
            [gravX , gravY] = calculateGravValues(X);
            
            totalGravX = totalGravX + gravX;
            totalGravY = totalGravY + gravY;
            
        end
        
    end

    
    % (3) : Gruplanm�� robotlar gruplanmam�� robotlar i�in
    % itim kuvveti olu�turur.
       tmp = getRobotObj;
    for j=1:length(getRobotObj)
        
        % s�radaki robot
        currentObj = tmp(j);
        
        if ( j~= val ) && ( isFullyGrouped(currentObj) == true )
            
            sX = currentObj.x;
            sY = currentObj.y;
            sM = currentObj.groupedMass;
            
            X = [fX , fY , fM ; sX , sY , sM ];
            
            if isRangeLimitEnough(X)
                [gravX , gravY] = calculateGravValues(X);
                
                totalGravX = totalGravX + gravX;
                totalGravY = totalGravY + gravY;
            end
        end
        
    end

    
    % Gruplanmam�� Robotlar i�in �ekim oklar� olu�turuluyor.
    % Ne zaman 
    if (rObj.groupedMass ~= pref.robotGroupedMass) && ( group == 0 ) && ( totalGravX + totalGravY ~=0 )

        rObj = generateArrow(totalGravX , totalGravY , rObj );       
    end
    
end



if group ~= 0 && ( isFullyGrouped(rObj) == true )% Gruplanm��sa
    
    if rObj.isLeader == 1   % ve liderse:
        
        % �evredeki Robotlar Onun i�in art�k iten g��t�r.
        tmp = getRobotObj;
        for j=1:length(getRobotObj)
            
            if ( j~= val )
                %s�radaki cisim se�ildi.
                currentObj  = tmp(j);
                
                if currentObj.groupID == 0
                    sX = currentObj.x;
                    sY = currentObj.y;
                    sM = currentObj.groupedMass; % Gruplanm�� robotlar�n itme kuvveti de�eri
                    
                    
                    X = [fX , fY , fM ; sX , sY , sM ];
                    
                    % E�er B�t�n Cisimlerin Etkisi Sisteme Kat�l�rsa:
                    % �oklu Cisim Eklendi�inde toplu bir itim kar��s�nda robot
                    % Di�er Robotlara veya hedefe gidebilmek i�in yeterli kuvvete sahip
                    % Olam�yor.
                    
                    if isRangeLimitEnough(X)
                        
                        [gravX , gravY] = calculateGravValues(X);
                        
                        totalGravX = totalGravX + gravX;
                        totalGravY = totalGravY + gravY;
                        
                    end
                end
            end
        end
        
        
        % Hedef ise onun i�in art�k �eken g��t�r. 
        tmp = getGoalObj;
        for j=1:length(tmp)
            
            % s�radaki cisim se�ildi.
            currentObj = tmp(j);
            
            sX = currentObj.x;
            sY = currentObj.y;
            sM = pref.hedefMass;
            
            X = [fX , fY , fM ; sX , sY , sM ];
            
            
            

                
                [gravX , gravY] = calculateGravValues(X);
                
                totalGravX = totalGravX + gravX;
                totalGravY = totalGravY + gravY;
                
            
            
        end
        
        % Gruplanm�� Robotlar i�in �ekim oklar� olu�turuluyor.
        if (rObj.gravLength ~= pref.gravLimit)
            rObj = generateArrow(totalGravX , totalGravY , rObj );
        end
        
 
    end
    
    if rObj.isLeader == -1  % ve k�leyse:
        
        % (1) : A��rl�k Merkezinin uygulad��� �ekme kuvveti vard�r.
        % A��rl�k Merkezi bulunacak. Panelde i�aretlenecek ve atanan
        % a��rl�k merkezi objesi return edilecek. Arg�man olarak robot
        % id'sini al�r.
        gravjObj = findAndMarkMassCenter(rObj.groupID);
        
        % A��rl�k Merkezinin Robotlar �zerine �ekimi bulunacak.
        
        sX = gravjObj.x;
        sY = gravjObj.y;
        sM = gravjObj.mass;
        
        X = [fX , fY , fM ; sX , sY , sM ];
               
        [gravX , gravY] = calculateGravValues(X);
        
        totalGravX = totalGravX + gravX;
        totalGravY = totalGravY + gravY;
        
        
        
        
        
        % (2) : Ayn� Grup i�erisindeki robotlar aras�nda bir itme kuvveti
        % vard�r.
        % k�le olan di�er robot bulunuyor.
        
        tmp = getRobotObj;
        arr  = getMeGroupRobots(rObj.groupID);

        
        for i = 1: length(arr)
            
            s = tmp(arr(i));
            if rObj.id ~= s.id && s.isLeader == -1
                otherSlave = s;
            end
        end
        
        sX = otherSlave.x;
        sY = otherSlave.y;
        sM = otherSlave.groupedMass;
        
         X = [fX , fY , fM ; sX , sY , sM ];
               
        [gravX , gravY] = calculateGravValues(X);
        
        totalGravX = totalGravX + gravX;
        totalGravY = totalGravY + gravY;
        
        
        
        
        
        
        
        
        
        
        % Gruplanm�� Robotlar i�in �ekim oklar� olu�turuluyor.
        if (rObj.gravLength ~= pref.gravLimit)
            rObj = generateArrow(totalGravX , totalGravY , rObj );
        end


        
    end
    
end




% robotObj degiskeninin degerleri guncelleniyor
tmp = getRobotObj;
tmp(val) = rObj;
setRobotObj(tmp);


% KULLANILMAYAN FONK.
% bir robota ait grup elemanlar�n� bulur ve gruptaki robot say�s�na bakar.
% belirlenen grup say�s�na sahipse true d�nd�r�r.
function grouped = isFullyGrouped(rObj)
grouped = false;

id = rObj.groupID;
res = getMeGroupRobots(id);
if id ~= 0
    if length(res) == pref.groupCount
        grouped = true;
    end
end


% Fonksiyon verilen limit de�erine bakarak cisimin hesaba kat�l�p
% kat�lmayaca��n�n sonucunu d�ner.
function limit = isRangeLimitEnough(X)

limit = false;

% ilk de�erler al�nd�.
f = X(1,:);
% ikinci de�erler al�nd�.
s = X(2,:);


arr = [f(1) , f(2) ; s(1) , s(2)];
distance = pdist(arr,'euclidean');

if distance <= pref.distanceLimit
limit = true;
end

function animation_Callback(hObject, eventdata, handles)


    % icon de�i�tiriliyor.
    X = imread('icons\stop.jpg');
    set(handles.animation,'CData',X);

hold on


% Her hareketten sonra degerleri update edilen veriler tabloya
% bastiriliyor. Eger tablodaki veri bir sonraki dongudeki bilgiyle ayniysa
% Hareket bitmis demektir. isActive false set edilir.
isActive = true;

while isActive

    tmp = getRobotObj;
    opt = getOptObj;
    % Tablodaki veri aliniyor.
    table = handles.uitable1;
    A = cell2mat( get(table , 'Data') );
    
    % Karsilastirilacak veri prev degiskenine kopyalaniyor.
    prev = A;
    
    for i = 1:length(getRobotObj)

        s = tmp(i);

        if ( s.gravLength < pref.gravLimit ) 
            
        % Degerler Alindi
        circleInfo  = s.circleObj;
        textInfo = s.textObj;
        color = s.color;

        % Robot Duzlemden Silindi
        delete(circleInfo);
        delete(textInfo);

       %Robot Yeni yerine set edilecek.
       % X ekseni: Force * cos(slope)
       % Y ekseni: Force * sin(slope)

       movingX = s.gravLength * cosd(s.gravSlope);
       movingY = s.gravLength * sind(s.gravSlope);

       X = (s.x)+movingX;
       Y = (s.y)+movingY;

       s.x = X;
       s.y = Y;

       % robotInfo degerleri guncelleniyor.
       circleInfo =  circles(X,Y,pref.circleRadius , 'facecolor' , color);
       
       % Robot Yollar�n� i�aretle se�ene�i a��ksa:
       if opt.robotPath == true
           circles(X,Y,0.05 , 'facecolor' , color , 'edgecolor' , color);
       end
       
       
%        if s.isLeader == 1
%            % Yeni sekil ataniyor.
%            circleInfo = circles(s.x, s.y , pref.circleRadius ,'facecolor' , s.color ,'edgecolor',[1 0 0],'linewidth',4);
%        end

       txt = text(X-0.1,Y,int2str(i));
       set(txt , 'FontSize',12);
       set(txt , 'FontWeight','bold');

       s.textObj = txt;
       s.circleObj = circleInfo;

       tmp(i) = s;
       setRobotObj(tmp);

       % Tablo Guncelleniyor.
       A(i , :) = [s.id s.x s.y];
       set(table , 'Data' , num2cell(A) );
          
       end
    end

    
    % Her Animasyondan sonra Grup olusturabilecek Robotlar Hesaplanacak.
    
    calculateGroups;
    
    % Foksiyon gruptaki eleman sayisini hesaplayacak ve grubu daire icine
    % alacak.
    
%     for i=1:length(getRobotObj)
%         tmp(i)
%     end
    
    calculateGroupCount;
    
 % Kutle cekimler Tekrar Hesaplanacak
   gravAlgorithm
   pause(.01);
  
   if prev == A
    isActive = false;
    
        % icon de�i�tiriliyor.
    X = imread('icons\play.jpg');
    set(handles.animation,'CData',X);

    
   end
   
end

hold off

function calculateGroups

tmp = getRobotObj;

% iki robot secilecek.
for i = 1:length(getRobotObj)
    rObj = tmp(i);
    
    for j = 1:length(getRobotObj)
        
        if i ~= j
            s = tmp(j);
            
            % Eger s.gravLength > pref.gravLimit ise robot bir gruba gelmis
            % ve burada durmus demektir.
            
            if s.gravLength > pref.gravLimit
                
                % Robotun pref.groupRadius degeri kadar yaricapta tarama
                % yapmasi saglaniyor.
                
                % Aradaki Fark hesaplaniyor ve mutlak degeri aliniyor.
                xDiff = abs(rObj.x - s.x);
                yDiff = abs(rObj.y - s.y);
                
                % Eger secilen robot bu aralikta ise bu robot grup
                % olusturubilecek nitelikte demektir.
                if xDiff <= pref.groupRadius && yDiff <= pref.groupRadius
                    
                    % secilen bu robotun herhangi bir grubu yok ise bir
                    % grup atanacak.
                    if s.groupID == 0
                        
                        % rObj nesnesi , bir gruba bagli olabilir.
                        % Eger oyleyse rObj grubuna dahil olacak.
                        
                        % Eger rObj'un da bir grubu yoksa; ikisi de yeni
                        % Bir gruba atanacak.
                        
                        % Atama yapilirken initial olarak isLeader = false 
                        if rObj.groupID == 0
                            
                            ID = getGroupCount + 1;
                            % Global Degiken Arttirildi.
                            setGroupCount(ID);
                            
                            % Group Idleri atandi
                            rObj.groupID = ID;
                            s.groupID = ID;                            
                            
                            % isLeader = false
                            rObj.isLeader = 0;
                            s.isLeader = 0;
                                                    
                            
                            % Array'a gonderiliyor
                            tmp(j) = s;
                            tmp(i) = rObj;
                            setRobotObj(tmp);
                            
                           % fprintf('%d ile %d ayni gruba atandilar.\n',i,j);
                           
                        else
                            % rObj groupId s e atandi.
                            s.groupID = rObj.groupID;
                            s.isLeader = 0;
                                         
                            % Array'a gonderiliyor
                            tmp(j) = s;
                            setRobotObj(tmp);
                           % fprintf('%d, %d nin grubuna atandi.\n',s.id,rObj.id);
                        end                                             
                    end                
                end              
                    
            end
        end
    end
end

function calculateGroupCount

tmp = getRobotObj;
countArr = [];

for i=1:getGroupCount
    
    for j = 1:length(getRobotObj)
        s = tmp(j);
        if s.groupID == i && s.mass ~= pref.robotGroupedMass
            countArr = [countArr s];
        end
    end
    
    if length(countArr) >= pref.groupCount
        
        
        % Kutle cekim Alanina Daire Ekleniyor.
        % NOT: E�er options nesnesinde bu se�enek i�aretli ise:
       
        opt = getOptObj;
        if opt.circleVisible
            avgX = ( countArr(1).x + countArr(2).x + countArr(3).x )/3;
            avgY = ( countArr(1).y + countArr(2).y + countArr(3).y )/3;
            
            
            hold on
            
            xCenter = avgX;
            yCenter = avgY;
            theta = 0 : 0.01 : 2*pi;
            radius = pref.groupRadius;
            x = radius * cos(theta) + xCenter;
            y = radius * sin(theta) + yCenter;
            plot(x, y);
            
            hold on
        end
        % Gruba elemanlarinin kutleleri pref.robotGroupedMass a cekiliyor.
        
        countArr(1).groupedMass = pref.robotGroupedMass;
        countArr(2).groupedMass = pref.robotGroupedMass;
        countArr(3).groupedMass = pref.robotGroupedMass;
        
        
        countArr(1).gravSlope = 0;
        countArr(1).gravLength = 0;
        
        countArr(2).gravSlope = 0;
        countArr(2).gravLength = 0;
        
        countArr(3).gravSlope = 0;
        countArr(3).gravLength = 0;
        
        % eraseArrows
        
        % Robot Array ine atama yapiliyor.
        tmp(countArr(1).id) = countArr(1);
        tmp(countArr(2).id) = countArr(2);
        tmp(countArr(3).id) = countArr(3);
        
        setRobotObj(tmp);
    end
    countArr = [];
end
            
function eraseArrows()

tmp = getRobotObj;

    for i=1:length(getRobotObj);
        s = tmp(i);
        if s.lineInfo ~= 0
            
            lineInfo = s.lineInfo;
            arrowInfo = s.arrowInfo;
            curveInfo = s.curveInfo;

            %Degerler Siliniyor.
            
            delete(lineInfo);
            delete(arrowInfo);
            delete(curveInfo);

            % robotInfo degerler icin guncelleniyor
            s.lineInfo = 0;
            s.arrowInfo = 0;
            s.curveInfo = 0;
            s.gravSlope = 0;
            s.gravLength = 0;
            
            tmp(i) = s;
            setRobotObj(tmp);
            
        end
    end
     

function eraseMass()
        
tmp = getMassObj;

for i = 1: length(getMassObj);
    s = tmp(i);
    
    circleObj = s.circleObj;
    
    if circleObj ~= 0
    % Degerler Siliniyor.
    delete(circleObj);
    
    end
    
    s.circleObj = 0;
    
    tmp(i) = s;
    setMassObj(tmp);
    
end

function robotSil_Callback(hObject, eventdata, handles)

 setIsPopupClicked( true );
type = gui_pop('Silinecek Eleman');
setIsPopupClicked( false );
hold on;   
eraseElementToPanel(type , handles);
hold off;

function printInfos_Callback(hObject, eventdata, handles)

tmp = getRobotObj;
for i=1:length(getRobotObj)
    s = tmp(i);
    s
end
tmp = getCisimObj;
for i=1:length(getCisimObj)
    s = tmp(i);
    s
end
tmp = getGoalObj;
for i=1:length(getGoalObj)
    s = tmp(i);
    s
end

function printObj
tmp = getRobotObj;
for i=1:length(getRobotObj)
    s = tmp(i);
    s
end

function res = getMemberByID(val)

result = [];
tmp = getRobotObj;
for i = 1:length(getRobotObj)
    s = tmp(i);
    if s.groupID == val
        result = [result s];
    end
end
res = result;

function liderAta_Callback(hObject, eventdata, handles)

for i= 1:getGroupCount
    
    isLeaderInit = false;
    tmp = getRobotObj;
    
    % Grub id sine ait butun robotlar bir array a ataniyor.
    res = getMemberByID(i);
    
    for j = 1:length(res)
        
       % Ayni robot id sine sahip robotlar arasinda
       % Secili olan robottan di�er robotlara gore bolge tespiti yapiliyor.
       % Belirlenen bolgeler array a ataniyor.
       
       % Yani; 
       % Ayni id ye ait her robot icin bir array olusturuluyor ve bu array
       % di�er robotlara ait bolge bilgisini tutuyor.
       % robotun index'i 0 ataniyor.
       areaArray = calculateArea(j,res);
       
       % areaArray'de herhangi iki rakam ayniysa robot kendini lider ilan
       % edecek. ( Bu durumla karsilasilan ilk robot kendisini ilan eder )
       if ( sum(areaArray == 1) == 2 || sum(areaArray == 2) == 2 || sum(areaArray == 3) == 2 || sum(areaArray == 4) == 2 ) &&  isLeaderInit ~= true 
           
%            areaArray
%            fprintf('Bu array Esit: %d \n ',j);
%            fprintf('Lider Secilecek Robot: %d \n ',res(j).id);
           
           % lider secilecek robotta isLeader 1 di�er robotlar icin -1
           % atanacak.
           tmp = setLeaderFromGroup(j , res);
           res = getMemberByID(i);
           
           
           % isLeaderInit true ataniyor. donguden cikilacak.
           isLeaderInit = true;
           
           % s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi
           
           % lider robot s e atandi.
           s = res(j);
           
           % lider robotun sekli di�er robotlardan farkli olacak. 
           % ( 4 px stroke )
           % ilk olarak sekil siliniyor.
           delete(s.circleObj);
           delete(s.textObj);
           
           s.circleObj = 0;
           s.textObj = 0;
           
           % Yeni sekil ataniyor.
           s.circleObj = circles(s.x, s.y , pref.circleRadius ,'facecolor' , s.color ,'edgecolor',[1 0 0],'linewidth',4);
           
           s.textObj = text(s.x-0.1,s.y,int2str(s.id));           % text adresi robot nesnesine atildi
           set(s.textObj , 'FontSize',12);
           set(s.textObj , 'FontWeight','bold');

           % butun bu de�erler tmp de�iskenine tekrar atiliyor ve global
           % de�iskene ataniyor.
           id = s.id;
           tmp(id) = s;
           
           setRobotObj(tmp);
           
       end
    end
end

function res = calculateArea(index,val)

result = [];
result(index) = 0; 

fX = val(index).x;
fY = val(index).y;
        
for i = 1:length(val)
    
    if i ~= index

        sX = val(i).x;
        sY = val(i).y;
        X = [fX , fY ; sX , sY];
        result(i) = determinePointArea(X);
    end
end

res = result;

function res = setLeaderFromGroup(index, val)
% lider secilen robot icin isLeader de�erini 1
% di�er robotlar icin 0 ayalayan fonksiyon.

tmp = getRobotObj;

for i=1:length(val)
    
    if i ~= index
        val(i).isLeader = -1;
        tmp(val(i).id) = val(i);
    end
    
end

% lider 1 atand�
val(index).isLeader = 1;
% a��rl�k merkezi hesab�nda kullan�lacak k�tle atand�.
val(index).centerOfMassValue = pref.leaderMass;

tmp(val(index).id) = val(index);

setRobotObj(tmp);
res = tmp;


% --------------------------------------------------------------------
function preferences_Callback(hObject, eventdata, handles)
% Se�enekler Al�n�yor.
tmp = getOptObj;

% Popup Menu a��ld�. callback durduruldu.
setIsPopupClicked( true );
% �nput paneline mevcut se�enekler aktar�l�yor ve sonu� al�yor.
tmpx = prefGUI(tmp);
setIsPopupClicked( false );
setOptObj(tmpx);

% foksiyon gruba ait a��rl�k merkezini bulur, panelde i�aretler ve bulunan
% a��rl�k merkezi objesini d�nd�r�r. Arg�man olarak robot id'sini al�r.
function obj = findAndMarkMassCenter(groupID)


   [massX , massY] =  findMassCenterByGroupID(groupID);
   
   % A��rl�k merkezi ekleniyor.
   
   s = agirlikInfo;
   s.groupID = groupID;   % merkeze ait grup
   s.x = massX;     % merkez X koordinat�
   s.y = massY;     % merkaz Y koordinat�
   s.mass = pref.merkezMass; % A��rl�k merkezinin sahip oldu�u k�tle
   
   s.circleObj = circles(massX,massY, 0.05 , 'facecolor' , 'black'); 
   
   % bu de�er e�er varsa i�eri�i de�i�tirilecek. yoksa yeniden
   % olu�turulacak.
   isExistVal = isExistOnMassCenter(groupID);
   
   if isExistVal == 0
       % de�erler nesneye atan�yor.
       setMassObj([getMassObj s]);
   else
       % de�erler de�i�tiliyor.
       tmp = getMassObj;
       tmpS = tmp(isExistVal);
       tmpS = s;
       setMassObj(tmpS);
   end
   
   obj = s;

% foksiyon verilen a��rl�k merkezi objesi i�inden grupid lerine g�re arama
% yapar ve grup id sini d�nd�r�r.

function res = isExistOnMassCenter(val)
tmp = getMassObj;

res = 0;

for i=1:length(tmp)
    s = tmp(i);
    if s.groupID == val
        res = i;
    end

end

% Fonksiyon verilen grup id sine g�re a��rl�k merkezi de�erlerini d�ner.
function [massX , massY] = findMassCenterByGroupID(val)

tmp = getRobotObj;
totalX = 0;
totalY = 0;
totalMass = 0;
arr = getMeGroupRobots(val);
%   leader = findLeader(arr);

for j=1:length(arr)
    
    s = tmp(arr(j));
    

    % G = (m1*x1 + m2*x2 + m3*x3)/(m1+m2+m3)
    
    % K�tle de hesaba kat�l�yor.
    totalX = totalX + s.x * s.centerOfMassValue;
    totalY = totalY + s.y * s.centerOfMassValue;
    
    totalMass = totalMass + s.centerOfMassValue;
    
    
%     fprintf('%d + %d \n',totalX,s.x * s.centerOfMassValue);
    
    
end

massX = totalX / totalMass;
massY = totalY / totalMass;

% foksiyon grup id sine g�re arama yapar ve gruba ait robotlar�n idlerini
% d�nd�r�r.
function tmp = getMeGroupRobots(val)
arr = [];
tmp = getRobotObj;
for i=1:length(getRobotObj)
    s = tmp(i);
    if s.groupID == val
        arr = [arr s.id];      
    end
end
tmp = arr;

% fonksiyon bir grupta liderin id sini bulur ve return eder
function res = findLeader(arr)

res = 0;
tmp = getRobotObj;

for i=1:length(arr)
    s = tmp(arr(i));
    if s.isLeader == 1
        res = s.id;
    end
end


% --------------------------------------------------------------------
function Menu_Callback(hObject, eventdata, handles)


% Fonksiyon b�t�n robot cisim ve hedeflerin konumlar�n� kaydedecek.
function saveScenario_Callback(hObject, eventdata, handles)

% Dosya Al�n�yor.

[FileName,PathName] = uiputfile('scenario.sec','Save Scenario');
file = strcat(PathName,FileName);
file = fopen(file,'w');


%Robotlar al�n�yor
tmp = getRobotObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Robot';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end


%Cisimler al�n�yor
tmp = getCisimObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Cisim';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end


%Hedefler al�n�yor
tmp = getGoalObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Hedef';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end

fclose(file);

% --------------------------------------------------------------------

function loadScenario_Callback(hObject, eventdata, handles)

%T�m Elemanlar siliniyor ve panel temzileniyor.
[FileName,PathName] = uigetfile('*.sec','Senaryo Se�iniz');
file = strcat(PathName,FileName);
fid = fopen(file,'r');
s = fscanf(fid , '%s');
res = strsplit(s, {',' , ';', ' ','\n'});


eraseElementToPanel('Robot',handles);
eraseElementToPanel('Cisim',handles);
eraseElementToPanel('Hedef',handles);
cla;

for i=1:3:length(res)-1
    X = str2double(res(i));
    Y = str2double(res(i+1));
    type = res(i+2);
    addElementToPanel(X , Y ,type , handles);
end



% --------------------------------------------------------------------
function Senaryo_Callback(hObject, eventdata, handles)
% hObject    handle to Senaryo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



