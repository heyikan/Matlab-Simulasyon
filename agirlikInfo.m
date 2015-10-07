classdef agirlikInfo
    % Gruba ait her a��rl�k merkezi de�eri i�in tutulacak de�erler.
    properties
        %% Robot Info
        groupID  % merkezi hesaplanan grubun id'si
        x        % merkezin x koodinati
        y       % merkezin y koordinati
        mass    % A��rl�k merkezinin sahip oldu�un k�tle
        %% Circle Info
        circleObj   % agirlik merkezi nesnesinin adresinin tutulacagi degisken
    end
end