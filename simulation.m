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


% koordinat duzlemi ayarlandi
xlim manual;
ylim manual;


lx = pref.panelWeight;
ly = pref.panelHeight;

xlim([0 lx]);
ylim([0 ly]);

axis([0,lx,0,ly]);
 axis equal;

 
 % Paneldeki axe adresi al�yor.
% gca : get current axes
panel = gcf;
 

% Panelde �zerine gelinerek se�ilecek robotlar� belirten daire nesnesinin
% adresini tutan global de�i�kenin ilk de�eri ve robot id'si 0 a atan�yor.
select = selectedObj;
select.circleID = 0;
select.robotID = 0;
select.laserCircle = 0;
select.linesObj = [];
setSelectedRobot(select);


handles.output = hObject;
guidata(hObject, handles);

set(gcf,'Pointer','fullcross');

% Event Listener: on mouse hover eventi ekleniyor
set(panel , 'WindowButtonMotionFcn' , @coordinate_callback)
% Event Listener: is mouse clicked eventi ekleniyor
set(panel , 'WindowButtonDownFcn' , {@ClicktoAdd_callback,handles})

function coordinate_callback (src,callbackdata)

selRobot = getSelectedRobot;
circle = selRobot.circleID;
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
        
        % Koordinat Bilgileri yaz�l�yor.
        s1 = num2str( posCurr(1) );
        s2 = num2str(posCurr(3) );
        res = strcat(s1,{' x '},s2);
        set(findobj('Tag' , 'coordinate') , 'String' , res );
        
        roboID = getMeIdByCoordinate(X , Y);
%         selID = selRobot.robotID 
        
%         avail = isAvailOnPanel(X,Y);
        if roboID ~= 0 && circle == 0 && roboID ~= selRobot.robotID 
           
            set(gcf,'Pointer','hand');
            
            tmp = getRobotObj;
            s = tmp(roboID);
            
            selRobot.robotID = roboID;
            selRobot.circleID = circles(s.x, s.y , pref.circleRadius ,'facecolor' , 'none','edgecolor',[1 0 0],'linewidth',4);

            setSelectedRobot(selRobot);
            
        
        else
            
            if circle ~= 0 && roboID ~= selRobot.robotID 
                
                set(gcf,'Pointer','fullcross');
                
                delete(circle);
                selRobot.circleID = 0;
                selRobot.robotID = 0;
                setSelectedRobot(selRobot);
           
            end
        end
        
    
               
        else
            set(findobj('Tag' , 'coordinate') , 'String' , '' );
            set(gcf,'Pointer','arrow');
       
        end

function ClicktoAdd_callback (src,callbackdata,handles)
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
        
        roboID = getMeIdByCoordinate(X , Y);

        % E�er panelde t�klan�lan yerde bir robot varsa, bu robot i�in
        % lazer range finder datas� olu�turulacak.
        if roboID ~= 0
            

            plotLaserRangeFinderForId(roboID);

        else

            hold on
            addElementToPanel(X , Y , handles);
            hold off
        end
        
    end
    

  
function addElementToPanel(X ,Y ,handles)
    
global s;


%robot ekleniyor
s = robotInfo; % Yeni nesne olusturuldu
s.id = length(getRobotObj) + 1;      % id Atandi

s.mass = pref.robotMass;             % Kutle Atandi
s.groupID = 0;                       % Group ID 0 Atandi
s.isLeader = 0;                      % Liderlik durumu false ayarlandi.
s.centerOfMassValue = pref.groupMemberMass;             % Grupland��� zaman kullan�cak k�tle de�eri  atand�
s.groupedMass = 0;                   % Robotlar hen�z gruplanmad�klar�ndan
% itme i�in kullan�lacak k�tle de�eri 0 atand�.
s.x = X;                             % x koorinati Atandi
s.y = Y;                             % y koorinati Atandi





s.color = randomColor;
s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi



%robot ID'si daire icine yazi olarak ekleniyor.
if s.id > 9
    s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
else
    s.textObj = text(X,Y,int2str(s.id));
end

set(s.textObj , 'FontSize',12);
set(s.textObj , 'FontWeight','bold');


setRobotObj([getRobotObj s]);
    
% Belirlenen koorinarlarda robot olup olmad���n� kontrol eder. e�er robot
% varsa id sini d�nd�r�r yoksa 0 d�nd�r�r.
function roboID = getMeIdByCoordinate( X , Y )

% Foksiyon robotlar, cisimler ve hedeflerde b�yle bir kordinat�n olup
% olmad���na bak�yor.
% E�er Se�ilen koordinat gruplanm�� robotlar�n bulundu�u bir alana denk
% gelmi�se de�er false d�necek.

tmp = getRobotObj;
roboID = 0;

for i=1:length(tmp)
    
    s = tmp(i);

    
    topLimitX  = s.x + pref.circleRadius;
    downLimitX = s.x - pref.circleRadius;
    
    topLimitY  = s.y + pref.circleRadius;
    downLimitY = s.y - pref.circleRadius;
    
     %fprintf('kontrol edilecek X: %3f Y:%3f \n' , s.x - X , s.y-Y);
    
    if X > s.x
        resX = topLimitX - X;
    end
    
    if X <= s.x
        resX = X - downLimitX;
    end
    
    if Y > s.y
        resY = topLimitY - Y;
    end
    
    if Y <= s.y    
        resY = Y - downLimitY;
    end
    
    if resX > 0 && resY > 0 && resX < pref.circleRadius && resY < pref.circleRadius
        roboID = s.id;
        break;

    end
    
end

function deleteRobot(id)

tmp = getRobotObj;
s = tmp(id);

delete(s.circleObj);
delete(s.textObj);

% Rbot idsi ile belirlenen robot i�in lazer �izgilerini panelede �izer ve
% her �izginin adresini array a atar.
function plotLaserRangeFinderForId(roboID)

% Robotlar al�nd�.
tmp = getRobotObj;
s = tmp(roboID);

% se�ili robot bilgileri al�nd�.
selRobot = getSelectedRobot;

if selRobot.laserCircle ~= 0
    delete(selRobot.laserCircle);
end
    selRobot.laserCircle = circles(s.x, s.y , laserInfo.range,'facecolor' , 'none','edgecolor',[0 0 1],'linewidth',2);
    setSelectedRobot(selRobot);


    % robot silinip tekrar y�klenecek.
    deleteRobot(s.id);
    
    % Daha �nceden �izilmi� lazer �izgileri varsa onlar alandan silinecek.
    allLines = selRobot.linesObj;
    
    for i=1:length(allLines)
        delete(allLines(i))
    end
    allLines = [];
    
    % Lazerin �evresinde bulunan robotlar bulunup array halinde de�i�kene
    % atan�yor.
%     foundedRobots = findRobotsForLazer(s.x , s.y );
    
    
    % lazer ���nlar� �iziliyor.
    for i=0:laserInfo.interval:360
        
        X = s.x;
        Y = s.y;
        
        % �izginin nereye kadar �izilece�i. �izilecek uzunluk sens�r�n
        % de�erini belirleyecek.
        limitX = s.x+laserInfo.range * cosd(i);
        limitY = s.y+laserInfo.range*sind(i);
        
        % �izilen �izgi do�rultusunda hi� robot var m� ona bak�l�yor.
        robotNum = isRobotExistForSlope(X , Y , limitX, limitY , i);
        if robotNum ~= 0
        % Lazerlerin y�zeyinden sens�r datas� ��kmas� i�in gerekli
        % ayarlamalar yap�l�yor.
            
        % g�nderilen lazer ���n� do�rultusunda bir robotun varl���
        % anla��ld�ktan sonra ���n�n sahip oldu�u uzunlu�un
        % belirlenmesi gerekiyor.
        % Limit X ve Limit Y de�erleri senkronize edilmeli.
        
        
        
            hold on
            plotObj = plot([X limitX] , [s.y limitY] , 'Color' , 'red' );
            hold off
            
        else
            hold on
            plotObj = plot([X limitX] , [s.y limitY] , 'Color' , 'blue' );
            hold off
        end
        
        allLines = [allLines plotObj];
        
    end
    

    
     hold on
    % robot tekrar ekleniyor
    s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi
    %robot ID'si daire icine yazi olarak ekleniyor.
    if s.id > 9
        s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
    else
        s.textObj = text(X,Y,int2str(s.id));
    end
    
    set(s.textObj , 'FontSize',12);
    set(s.textObj , 'FontWeight','bold');
    hold off
    
    % robot silinip tekar y�klendi�i i�in g�ncelleniyor.
    tmp(roboID) = s;
    setRobotObj(tmp);
    
    % �izgiler nesneye atan�yor.
    selRobot.linesObj = allLines;
     setSelectedRobot(selRobot);   
    
    
    
% Lazer sens�r� aktif olan bir robot i�in, sens�r i�erisinde bulunan b�t�n 
% robotlar�n idsini d�nen foksiyon.    
function arr = findRobotsForLazer(X , Y )
% Robotlar al�nd�.
tmp = getRobotObj;

arr = [];
diffX=0;
diffY=0;

for i=1:length(tmp)

s = tmp(i);

if s.x >= X
    diffX = s.x - X;
end

if s.x < X
    diffX = X - s.x;
end

if s.y >= Y
    diffY = s.y - Y;
end

if s.y < Y
    diffY = Y-s.y;
end

if diffX <= laserInfo.range && diffY <= laserInfo.range && diffX+diffY ~= 0
arr = [arr s.id];
end

end

% Lazerden ��kan ���n�n do�rultusuna bakarak bu do�rultu �zerinde robot 
% olup olmad���n� kontrol eden foksiyon.
function robot = isRobotExistForSlope(X , Y , limitX, limitY , slope)

robot = 0;

limitI = floor(laserInfo.range / ( pref.circleRadius * 2));

for i=1:limitI

currY = sind(slope) * pref.circleRadius * i * 2 + Y;
currX = cosd(slope) * pref.circleRadius * i * 2 + X;

roboid = getMeIdByCoordinate(currX , currY );

% circles(currX,currY, 0.1 , 'facecolor' , 'red');

if roboid ~= 0
    robot = roboid;
    break;
end

end



% Robotlarin Adreslerini tutan global degisken.
function setRobotObj(val)
global robotObj
robotObj = val;

function r = getRobotObj
global robotObj
r = robotObj;


function setSelectedRobot(val)
global selectObj
selectObj = val;

function r = getSelectedRobot
global selectObj
r = selectObj;
    

function varargout = simulation_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


