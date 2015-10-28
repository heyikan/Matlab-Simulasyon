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
setSelectedRobot(select);


handles.output = hObject;
guidata(hObject, handles);

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
           
            tmp = getRobotObj;
            s = tmp(roboID);
            
            selRobot.robotID = roboID;
            selRobot.circleID = circles(s.x, s.y , pref.circleRadius ,'facecolor' , 'none','edgecolor',[1 0 0],'linewidth',4);
            
            
            setSelectedRobot(selRobot);
            
        
        else
            
            if circle ~= 0 && roboID ~= selRobot.robotID 
            delete(circle);
            selRobot.circleID = 0;
            selRobot.robotID = 0;
            setSelectedRobot(selRobot);
            

            end
        end
        
        
        

        set(gcf,'Pointer','fullcross');
        

                
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
        %      type = choosedialog('Eklenecek Eleman:');
    end
    
    hold on
    addElementToPanel(X , Y , handles);
    hold off
  
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
    
%     fprintf('kontrol edilecek X: %3f Y:%3f \n' , s.x - X , s.y-Y);
    
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







% avail = isAvail;

    
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


