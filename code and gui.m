% ===================================================
% ======================= GUI =======================
% ===================================================
% 1180414 Yazan Daibes
% 1181219 Lana Abu Hammad
% 1183229 Mohammad Balawi
function varargout = gui(varargin)
    global Fs;
    global n;
    global outputname;
    global train_file;  

    Fs = 8000;
    n = 0:320;
    outputname = "output.wav";
    train_file = "enc1_sound.wav";
    
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
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
end

function gui_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    imshow("bg.png");
    guidata(hObject, handles);
end

function varargout = gui_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end

function edit1_Callback(hObject, eventdata, handles)
end

function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function edit3_Callback(hObject, eventdata, handles)
end

function edit3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function pushbutton1_Callback(hObject, eventdata, handles)
    global outputname;
    global encode_path;
    
    path = uigetdir()
    if(isequal(path, 0))
        set(hObject,'String','No Directory Selected');
    else
        set(hObject,'String',path);
        encode_path = append(path,'\',outputname);
    end
end

function pushbutton4_Callback(hObject, eventdata, handles)
    global Fs;
    global n;
    global encode_path;
    global outputname;
    
    if (isequal(get(handles.pushbutton1, 'String'), 'No Directory Selected'))
        msgbox('Please Select a Directory to Output WAV File');
    elseif (get(handles.edit1, 'String') == "")
        msgbox('Please Type Input String');
    else
        audio = readString(get(handles.edit1, 'String'),n,Fs,encode_path);
        %sound(audio,Fs);
        msgbox('Successfully Encoded, file name: output.wav');
    end
end

function pushbutton5_Callback(hObject, eventdata, handles)
    global decode_path;
    [file,path] = uigetfile('*.wav');

    if isequal(file,0)
       set(hObject,'String','No WAV File Selected');
    else
       set(hObject,'String',fullfile(path,file));
       decode_path = fullfile(path,file);
    end
end

function pushbutton6_Callback(hObject, eventdata, handles)
	global decode_path;
    if(isequal(get(handles.pushbutton5, 'String'), 'No WAV File Selected'))
        msgbox('Please Choose WAV File');
    else
        set(handles.edit3, 'String', decode_filter(decode_path))
    end
end

function pushbutton12_Callback(hObject, eventdata, handles)
	global decode_path;
    if(isequal(get(handles.pushbutton5, 'String'), 'No WAV File Selected'))
        msgbox('Please Choose WAV File');
    else
        set(handles.edit3, 'String', decode_fft(decode_path))
    end
end
% ===================================================
% ===================== GUI END =====================
% ===================================================

function decoded_string = decode_fft(decode_path)
    global Fs;  
    global train_file; 
    
    t =0:1/Fs:320/Fs;
    divided_seg = divideSeg(train_file);
    [rownum,colnum] = size(divided_seg); 
    peaks = zeros(53,4);

    for i = 1:colnum
       segSetFrequencyDomain{i} = fft(divided_seg(:,i),256);
       segSetFrequencyDomain{i} = abs(segSetFrequencyDomain{i}(1:130));
    end 

    temp=[];
    s = '';
    for j = 1:colnum
        [p1,p2,p3,p4] = maxPeak(segSetFrequencyDomain{j});
        [c1,c2,c3,c4] = findNearest(p1,p2,p3,p4);
        peaks(j,1)= c1;
        peaks(j,2)= c2;
        peaks(j,3)= c3;
        peaks(j,4)= c4;   
    end

    divided_seg2 = divideSeg(decode_path);
    [rownum2,colnum2] = size(divided_seg2); 

    for i = 1:colnum2 
        for j = 1:53
            if isequal(divided_seg2(:,i),divided_seg(:,j)) == 1
                s = strcat(s,mapFreqToChar(peaks(j,1),peaks(j,2),peaks(j,3),peaks(j,4)));
                break;
            end
        end
    end 
    decoded_string = s;
end

function sound_wav = readString(s,n,Fs,encode_path)
  for i = 1:strlength(s)
      f1 = 100;
      if ( isstrprop(s(i),'upper') )
          f1=200;
      end 
      [f2,f3,f4] = mapCharToFreq(lower(s(i)));
      q{i} = generate_wav(f1,f2,f3,f4,n,Fs);
  end
  total = Concatenate(q);
  % plot(q{1});
  sound_wav = generate_audio(encode_path,total,Fs);
  end

function wav = generate_wav(f1,f2,f3,f4,n,Fs)
  wav = cos(2*pi*(n/Fs)*f1) + cos(2*pi*f2*((n/Fs)))+ cos(2*pi*f3*((n/Fs)))+cos(2*pi*f4*((n/Fs)));
end

function con = Concatenate(q)
   con = [q{:}];
end

function aud = generate_audio(encode_path,total,Fs)
   audiowrite(encode_path,total,Fs); 
   [aud,s] = audioread(encode_path); 
end

function [f2,f3,f4] = mapCharToFreq(c)
    switch c
        case 'a' 
            [f2,f3,f4] = deal(400,800,1600);
        case 'b' 
            [f2,f3,f4] = deal(400,800,2400);
        case 'c' 
            [f2,f3,f4] = deal(400,800,4000);
        case 'd' 
            [f2,f3,f4] = deal(400,1200,1600);
        case 'e' 
            [f2,f3,f4] = deal(400,1200,2400);
        case 'f' 
            [f2,f3,f4] = deal(400,1200,4000);
        case 'g' 
            [f2,f3,f4] = deal(400,1600,2000);
        case 'h' 
            [f2,f3,f4] = deal(400,2000,2400);
        case 'i' 
            [f2,f3,f4] = deal(400,2000,4000);
        case 'j' 
            [f2,f3,f4] = deal(600,800,1600);
        case 'k' 
            [f2,f3,f4] = deal(600,800,2400);
        case 'l' 
            [f2,f3,f4] = deal(600,800,4000);
        case 'm' 
            [f2,f3,f4] = deal(600,1200,1600);
        case 'n' 
            [f2,f3,f4] = deal(600,1200,2400);
        case 'o' 
            [f2,f3,f4] = deal(600,1200,4000);
        case 'p' 
            [f2,f3,f4] = deal(600,1600,2000);
        case 'q' 
            [f2,f3,f4] = deal(600,2000,2400);
        case 'r' 
            [f2,f3,f4] = deal(600,2000,4000);
        case 's' 
            [f2,f3,f4] = deal(800,1000,1600);
        case 't' 
            [f2,f3,f4] = deal(800,1000,2400);
        case 'u' 
            [f2,f3,f4] = deal(800,1000,4000);
        case 'v' 
            [f2,f3,f4] = deal(1000,1200,1600);
        case 'w' 
            [f2,f3,f4] = deal(1000,1200,2400);
        case 'x' 
            [f2,f3,f4] = deal(1000,1200,4000);
        case 'y' 
            [f2,f3,f4] = deal(1000,1600,2000);
        case 'z' 
           [f2,f3,f4] = deal(1000,2000,2400);
        case ' ' 
            [f2,f3,f4] = deal(1000,2000,4000);
        
        otherwise
            warning('Unexpected Character type.')
    end
end


function output = divideSeg(decode_path)
    [x,fs] = audioread(decode_path);
    matSize = 321;
    output = vec2mat(x,matSize)';  
end

function [F1,F2,F3,F4] = maxPeak(x)
    [pks,locs] = findpeaks(x(1:round(length(x))));
    [sortedX, sortedInds] = sort(pks(:),'descend');
    sortedInds = [sortedInds(1),sortedInds(2),sortedInds(3),sortedInds(4)];
    sortedInds = sort(sortedInds);
    F1 = locs(sortedInds(1))*31; 
    F2 = locs(sortedInds(2))*31;
    F3 = locs(sortedInds(3))*31;
    F4 = locs(sortedInds(4))*31;
end

function [minVal_1,minVal_2,minVal_3,minVal_4] = findNearest(F1,F2,F3,F4)
    a=[100 200 400 600 800 1000 1200 1600 2000 2400 4000];
    [val,idx]=min(abs(a-F1));
    minVal_1=a(idx);
    [val,idx2]=min(abs(a-F2));
    minVal_2=a(idx2);
    [val,idx3]=min(abs(a-F3));
    minVal_3=a(idx3);
    [val,idx4]=min(abs(a-F4));
    minVal_4=a(idx4);
end

function char = mapFreqToChar(f1,f2,f3,f4)
   char = '';
   if f1 == 100 && f2 == 400 && f3 == 800 && f4 ==1600
        char = 'a';
   end
   if f1 == 100 && f2 == 400 && f3 == 800 && f4 ==2400
        char = 'b';
   end
   if f1 == 100 && f2 == 400 && f3 == 800 && f4 ==4000
        char = 'c';
   end
   if f1 == 100 && f2 == 400 && f3 == 1200 && f4 ==1600
        char = 'd';
   end
   if f1 == 100 && f2 == 400 && f3 == 1200 && f4 ==2400
        char = 'e';
   end
   if f1 == 100 && f2 == 400 && f3 == 1200 && f4 ==4000
        char = 'f';
   end
   if f1 == 100 && f2 == 400 && f3 == 1600 && f4 ==2000
        char = 'g';
   end
   if f1 == 100 && f2 == 400 && f3 == 2000 && f4 ==2400
        char = 'h';
   end
   if f1 == 100 && f2 == 400 && f3 == 2000 && f4 ==4000
        char = 'i';
   end
   if f1 == 100 && f2 == 600 && f3 == 800 && f4 ==1600
        char = 'j';
   end
   if f1 == 100 && f2 == 600 && f3 == 800 && f4 ==2400
        char = 'k';
   end
   if f1 == 100 && f2 == 600 && f3 == 800 && f4 ==4000
        char = 'l';
   end
   if f1 == 100 && f2 == 600 && f3 == 1200 && f4 ==1600
        char = 'm';
   end
   if f1 == 100 && f2 == 600 && f3 == 1200 && f4 ==2400
        char = 'n';
   end
   if f1 == 100 && f2 == 600 && f3 == 1200 && f4 ==4000
        char = 'o';
   end
   if f1 == 100 && f2 == 600 && f3 == 1600 && f4 ==2000
        char = 'p';
   end
   if f1 == 100 && f2 == 600 && f3 == 2000 && f4 ==2400
        char = 'q';
   end
   if f1 == 100 && f2 == 600 && f3 == 2000 && f4 ==4000
        char = 'r';
   end
   if f1 == 100 && f2 == 800 && f3 == 1000 && f4 ==1600
        char = 's';
   end
   if f1 == 100 && f2 == 800 && f3 == 1000 && f4 ==2400
        char = 't';
   end
   if f1 == 100 && f2 == 800 && f3 == 1000 && f4 ==4000
        char = 'u';
   end
   if f1 == 100 && f2 == 1000 && f3 == 1200 && f4 == 1600
        char = 'v';
   end
   if f1 == 100 && f2 == 1000 && f3 == 1200 && f4 == 2400
        char = 'w';
   end
   if f1 == 100 && f2 == 1000 && f3 == 1200 && f4 == 4000
        char = 'x';
   end
   if f1 == 100 && f2 == 1000 && f3 == 1600 && f4 == 2000
        char = 'y';
   end
   if f1 == 100 && f2 == 1000 && f3 == 2000 && f4 == 2400
        char = 'z';
   end
   if f1 == 100 && f2 == 1000 && f3 == 2000 && f4 == 4000
        char = " ";
   end
   if f1 == 200 && f2 == 400 && f3 == 800 && f4 ==1600
        char = 'A';
   end
   if f1 == 200 && f2 == 400 && f3 == 800 && f4 ==2400
        char = 'B';
   end
   if f1 == 200 && f2 == 400 && f3 == 800 && f4 ==4000
        char = 'C';
   end
   if f1 == 200 && f2 == 400 && f3 == 1200 && f4 ==1600
        char = 'D';
   end
   if f1 == 200 && f2 == 400 && f3 == 1200 && f4 ==2400
        char = 'E';
   end
   if f1 == 200 && f2 == 400 && f3 == 1200 && f4 ==4000
        char = 'F';
   end
   if f1 == 200 && f2 == 400 && f3 == 1600 && f4 ==2000
        char = 'G';
   end
   if f1 == 200 && f2 == 400 && f3 == 2000 && f4 ==2400
        char = 'H';
   end
   if f1 == 200 && f2 == 400 && f3 == 2000 && f4 ==4000
        char = 'I';
   end
   if f1 == 200 && f2 == 600 && f3 == 800 && f4 ==1600
        char = 'J';
   end
   if f1 == 200 && f2 == 600 && f3 == 800 && f4 ==2400
        char = 'K';
   end
   if f1 == 200 && f2 == 600 && f3 == 800 && f4 ==4000
        char = 'L';
   end
   if f1 == 200 && f2 == 600 && f3 == 1200 && f4 ==1600
        char = 'M';
   end
   if f1 == 200 && f2 == 600 && f3 == 1200 && f4 ==2400
        char = 'N';
   end
   if f1 == 200 && f2 == 600 && f3 == 1200 && f4 ==4000
        char = 'O';
   end
   if f1 == 200 && f2 == 600 && f3 == 1600 && f4 ==2000
        char = 'P';
   end
   if f1 == 200 && f2 == 600 && f3 == 2000 && f4 ==2400
        char = 'Q';
   end
   if f1 == 200 && f2 == 600 && f3 == 2000 && f4 ==4000
        char = 'R';
   end
   if f1 == 200 && f2 == 800 && f3 == 1000 && f4 ==1600
        char = 'S';
   end
   if f1 == 200 && f2 == 800 && f3 == 1000 && f4 ==2400
        char = 'T';
   end
   if f1 == 200 && f2 == 800 && f3 == 1000 && f4 ==4000
        char = 'U';
   end
   if f1 == 200 && f2 == 1000 && f3 == 1200 && f4 == 1600
        char = 'V';
   end
   if f1 == 200 && f2 == 1000 && f3 == 1200 && f4 == 2400
        char = 'W';
   end
   if f1 == 200 && f2 == 1000 && f3 == 1200 && f4 == 4000
        char = 'X';
   end
   if f1 == 200 && f2 == 1000 && f3 == 1600 && f4 == 2000
        char = 'Y';
   end
   if f1 == 200 && f2 == 1000 && f3 == 2000 && f4 == 2400
        char = 'Z';
   end
end

% phase 2 filters ======================================================
function decoded_string = decode_filter(decode_path)
    global train_file;
    global Fs;
    t =0:1/Fs:320/Fs;
    divided_seg = divideSeg(train_file);
    [rownum,colnum] = size(divided_seg); 
    max_energies = zeros(53,4);
    
    % filters design at each letter frequency as well as at the upper/lower cases
    filter_100 = fir1(48,[0.024 0.027],'bandpass'); % [96Hz - 104Hz]
    filter_200 = fir1(48,[0.04 0.06],'bandpass');  % [160Hz - 240Hz]
    filter_400 = fir1(48,[0.09 0.11],'bandpass'); % [ 360Hz - 440Hz ]
    filter_600 = fir1(48,[0.14 0.16],'bandpass'); % [560Hz - 640Hz ]
    filter_800 = fir1(48,[0.19 0.21],'bandpass'); % [760Hz - 840Hz ]
    filter_1000 = fir1(48,[0.24 0.26],'bandpass'); % [960Hz - 1040Hz]
    filter_1200 = fir1(48,[0.29 0.31],'bandpass'); % [1160Hz - 1240Hz]
    filter_1600 = fir1(48,[0.39 0.41],'bandpass'); % [1560Hz - 1640Hz]
    filter_2000 = fir1(48,[0.49 0.51],'bandpass'); % [1960Hz - 2040Hz]
    filter_2400 = fir1(48,[0.59 0.61],'bandpass'); % [2360Hz - 2440Hz]
    filter_4000 = fir1(48,[0.75 0.9999999999] ,'bandpass');

    for i = 1:colnum
        % filter 100 Hz
        filt1 = filter(filter_100,1,divided_seg(:,i));
        s_100 = sum(abs(filt1));
        energy_100 = pow2(s_100);
        
        % filter 200 Hz  
        filt2 = filter(filter_200,1,divided_seg(:,i));
        s_200 = sum(abs(filt2));    
        energy_200 = pow2(s_200);

        % filter 400 Hz    
        filt3 = filter(filter_400,1,divided_seg(:,i));
        s_400 = sum(abs(filt3));
        energy_400 = pow2(s_400);

         % filter 600 Hz    
        filt4 = filter(filter_600,1,divided_seg(:,i));
        s_600 = sum(abs(filt4));
        energy_600 = pow2(s_600);

        % filter 800 Hz    
        filt5 = filter(filter_800,1,divided_seg(:,i));
        s_800 = sum(abs(filt5));
        energy_800 = pow2(s_800);

        % filter 1000 Hz    
        filt6 = filter(filter_1000,1,divided_seg(:,i));
        s_1000 = sum(abs(filt6));
      %  fprintf("sum_1000 = %d \n",s_1000);
        energy_1000 = pow2(s_1000);
      %  fprintf("power_1000 = %d \n",power_1000);

        % filter 1200 Hz    
        filt7 = filter(filter_1200,1,divided_seg(:,i));
        s_1200 = sum(abs(filt7));
        energy_1200 = pow2(s_1200);

        % filter 1600 Hz    
        filt8 = filter(filter_1600,1,divided_seg(:,i));
        s_1600 = sum(abs(filt8));
        energy_1600 = pow2(s_1600);        

        % filter 2000 Hz    
        filt9 = filter(filter_2000,1,divided_seg(:,i));
        s_2000 = sum(abs(filt9));
        energy_2000 = pow2(s_2000);    

        % filter 2400 Hz    
        filt10 = filter(filter_2400,1,divided_seg(:,i));
        s_2400 = sum(abs(filt10));
        energy_2400 = pow2(s_2400);

        % filter 4000 Hz    
        filt11 = filter(filter_4000,1,divided_seg(:,i));
        s_4000 = sum(abs(filt11));
        energy_4000 = pow2(s_4000);

        energy_arr_2F = [energy_100 energy_200]; % power of the upper/lower cases
        energy_arr_9F = [energy_400 energy_600 energy_800 energy_1000 energy_1200 energy_1600 energy_2000 energy_2400 energy_4000]; % power of letter frequencies
        [f1,f2,f3,f4] = find4Freqs(energy_arr_2F,energy_arr_9F);

        max_energies(i,1) = f1;
        max_energies(i,2) = f2;
        max_energies(i,3) = f3;
        max_energies(i,4) = f4;

    end


    divided_seg2 = divideSeg(decode_path);
    [rownum2,colnum2] = size(divided_seg2); 

    s = '';
    for i = 1:colnum2 
        for j = 1:53
            if isequal(divided_seg2(:,i),divided_seg(:,j)) == 1
                s = strcat(s,mapFreqToChar(max_energies(j,1),max_energies(j,2),max_energies(j,3),max_energies(j,4)));
                break;
            end
        end
    end 
    decoded_string = s;
end


function [F1,F2,F3,F4] = find4Freqs(energies_2F,energies_9F)
    caseFreqs =[100 200]; %  upper/lower case frequencies
    allFreqs=[400 600 800 1000 1200 1600 2000 2400 4000]; % letter frequencies
  
    [max_case,I_case ] = max(energies_2F); % get the max power of the upper/lower case
    [max3energies,I]= maxk(energies_9F,3); % get the 3 maxs power of letter 
    
    sortedI = sort(I); % sort the letters indeindices (ascending) 
    
    F1 = caseFreqs(I_case);
    F2 = allFreqs(sortedI(1));
    F3 = allFreqs(sortedI(2));
    F4 = allFreqs(sortedI(3));
end