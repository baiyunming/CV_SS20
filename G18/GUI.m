function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 07-Jul-2020 22:13:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

%% Default Settings
% Set interrupt
global stop_now;
stop_now=0;
% set global variables
global frame_counter;
frame_counter = 0;
global current_ind;
current_ind=1;
handles.start=1;
handles.loop=0;
% Set default source
handles.src='dataset/default';
handles.dest = "output.avi";
% Select rendering mode
handles.render_mode = "substitute";
% Store Output?
handles.store = false;
% Choose default command line output for GUI
handles.output = hObject;
% Set mode
if get(handles.radiobutton1,'value')
    handles.render_mode="background";
elseif get(handles.radiobutton2,'value')
    handles.render_mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.render_mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.render_mode="substitute";
end
% Select Cameras
handles.L=1;
handles.R=2;
% Set loop mode
if get(handles.radiobutton11,'value')
    handles.loop_on=true;
else
    handles.loop_on=false;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% pushbutton: select folder path
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.src = uigetdir('','Select directory of videos');
global current_ind;
if handles.start>0
    current_ind = handles.start;
else
    current_ind = 1;
end
% Update handles structure
guidata(hObject, handles);

%% pushbutton: import background
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name, file_path]=uigetfile('*.jpg;*.tif;*.png;*.bmp;*.avi;*.mp4','Select background file');
try
    [~,~,file_type]=fileparts(file_name);
if file_type==".jpg" || file_type==".tif"|| file_type==".png"|| file_type==".bmp"
    bg=imread([file_path,file_name]);
else
    bg=VideoReader([file_path,file_name]);
end
handles.bg = bg;
catch
    % msgbox('No backgound is imported! Please choose a file!');
end
% Update handles structure
guidata(hObject, handles);

%% pushbutton: set video save path
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file_name, file_path]=uiputfile('Output.avi','Result video save as..');
handles.dest = [file_path,file_name];
try
    handles.v=VideoWriter(handles.dest,'Motion JPEG AVI');
    handles.store = true;
catch 
    % msgbox('No new video file is created!','error');
end
handles.v.FrameRate=30;
% Update handles structure
guidata(hObject, handles);

%% set start frame
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
str=get(hObject,'string');
if isempty(str2num(str))
    msgbox('Start frame must be an integer!','Error');
    set(hObject,'string','0')
else
    handles.start=str2num(get(hObject,'String'));
end
global current_ind;
current_ind = handles.start;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
handles.start=1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Update handles structure
guidata(hObject, handles);

%% pushbutton: stop
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stop_now
stop_now = 1;
if handles.store
    close(handles.v);
end
%msgbox("Stopped!");
% Update handles structure
guidata(hObject, handles);

%% radiobutton: loop
% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11
if get(handles.radiobutton11,'value')
    handles.loop_on=true;
else 
    handles.loop_on=false;
end
% Update handles structure
guidata(hObject, handles);

%% pushbutton: start
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check stop
global stop_now
stop_now=0;
global current_ind;
global frame_counter;
% Open video
if handles.store
    open(handles.v);
end
% Set up ImagerReader
% Choose the number of succseeding frames
N=100;
% Check if it is the first loop
new_round=1;
% Set loop mode
if get(handles.radiobutton11,'value')
    handles.loop_on=true;
end
% set render mode
if get(handles.radiobutton1,'value')
    handles.render_mode="background";
elseif get(handles.radiobutton2,'value')
    handles.render_mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.render_mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.render_mode="substitute";
end
% set Cameras
if get(handles.radiobutton12,'value')
    handles.L=1;
    handles.R=2;
elseif get(handles.radiobutton13,'value')
    handles.L=2;
    handles.R=3;
end
% process frame by frame
try
while (new_round==1||handles.loop_on==true)&& stop_now ~=1
    % msgbox(num2str(handles.start));
    ir = ImageReader(handles.src, handles.L, handles.R, handles.start, N);
    % Set new_round=0 when entering the first loop
    new_round=0;
    while handles.loop ~= 1 && stop_now ~=1
        %if first loop or frame_counter reach threhold: update update background by reading next N (for example 60) images
        if frame_counter==0 ||frame_counter==100
            ir.N = 100;
            frame_counter=1;
        else
        %no need to update the background, only read next 1 image
            ir.N =1;
        end
      % Get next image tensors
      [left,right,handles.loop]=ir.next();
      axes(handles.axes2);
      imshow(left(:,:,1:3));
      % Generate binary mask
      mask=segmentation(left,right);
      % Render new frame
      result=render(left(:,:,1:3),mask,handles.bg,handles.render_mode);
      axes(handles.axes3);
      imshow(result);
      %% Write Movie to Disk
      if handles.store && handles.v.IsOpen
        writeVideo(handles.v,result);
      end
      frame_counter=frame_counter+1;
      drawnow;
    end
    frame_counter=0;
    if handles.loop_on==true
        handles.loop=0;
    end 
end
if handles.loop==1
    current_ind=handles.start;
    handles.loop=0;
end
if handles.store
    close(handles.v);
    msgbox('Video saved!','Success');
end
catch
      handles.loop=0;
      msgbox('Some inputs are missing or invaild. Please check the inputs and try again.','error','Error');
end

% Update handles structure
guidata(hObject, handles);

%% set render mode
% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.radiobutton1,'value',1);
set(handles.radiobutton2,'value',0);
set(handles.radiobutton3,'value',0);
set(handles.radiobutton4,'value',0);
if get(handles.radiobutton1,'value')
    handles.render_mode="background";
elseif get(handles.radiobutton2,'value')
    handles.render_mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.render_mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.render_mode="substitute";
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.radiobutton1,'value',0);
set(handles.radiobutton2,'value',1);
set(handles.radiobutton3,'value',0);
set(handles.radiobutton4,'value',0);
if get(handles.radiobutton1,'value')
    handles.render_mode="background";
elseif get(handles.radiobutton2,'value')
    handles.render_mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.render_mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.render_mode="substitute";
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
set(handles.radiobutton1,'value',0);
set(handles.radiobutton2,'value',0);
set(handles.radiobutton3,'value',1);
set(handles.radiobutton4,'value',0);
if get(handles.radiobutton1,'value')
    handles.render_mode="background";
elseif get(handles.radiobutton2,'value')
    handles.render_mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.render_mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.render_mode="substitute";
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
set(handles.radiobutton1,'value',0);
set(handles.radiobutton2,'value',0);
set(handles.radiobutton3,'value',0);
set(handles.radiobutton4,'value',1);
if get(handles.radiobutton1,'value')
    handles.mode="background";
elseif get(handles.radiobutton2,'value')
    handles.mode="foreground";
elseif get(handles.radiobutton3,'value')
    handles.mode="overlay";
elseif get(handles.radiobutton4,'value')
    handles.mode="substitute";
end
% Update handles structure
guidata(hObject, handles);

%% set camera
% --- Executes on button press in radiobutton12.
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton12
set(handles.radiobutton12,'value',1);
set(handles.radiobutton13,'value',0);
if get(handles.radiobutton12,'value')
    handles.L=1;
    handles.R=2;
elseif get(handles.radiobutton13,'value')
    handles.L=2;
    handles.R=3;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton13.
function radiobutton13_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton13
set(handles.radiobutton12,'value',0);
set(handles.radiobutton13,'value',1);
if get(handles.radiobutton12,'value')
    handles.L=1;
    handles.R=2;
elseif get(handles.radiobutton13,'value')
    handles.L=2;
    handles.R=3;
end
% Update handles structure
guidata(hObject, handles);
