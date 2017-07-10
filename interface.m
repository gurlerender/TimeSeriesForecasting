function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 18-Apr-2016 10:37:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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
end

% --- Executes just before interface is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

% Choose default command line output for interface
if(~isempty(varargin))
    handles=varargin{:}.ex;
end

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in btnForecast.
function btnForecast_Callback(hObject, eventdata, handles)
% hObject    handle to btnForecast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'targetDataPath') == 1
    input = xlsread(handles.targetDataPath);
    TargetSeries=input.';
    TargetSeries=num2cell(TargetSeries);
    weight =handles.weight;
    weight=weight.';
    bestNet = handles.bestNet;
else
    Y = load(handles.loadDataPath);
    bestNet = Y.X.bestNet;
    weight = Y.X.weight;
    weight=weight.';
    TargetSeries = Y.X.targetSeries;
end 
    
forecastStep=str2double(get(handles.edtForcast,'String'));
net = setwb(bestNet,weight);
Forecastdata = TargetSeries(1,:);
XX = length(Forecastdata);
YY = cell2mat(Forecastdata);
YY(1,end+forecastStep) = 0;
Forecastdata = num2cell(YY);
h = waitbar(0,'Forecasting...','Name','Training');
for i=1:forecastStep
nets = removedelay(net);
[xs,xis,ais] = preparets(nets,{},{},Forecastdata(1,1:XX));
ys = nets(xs,xis,ais);
Forecastdata(1,XX+1) = ys(1,end);
set(handles.listValue,'string',cell2mat(Forecastdata(1,length(TargetSeries):end)));
XX = XX+1;
waitbar(i /forecastStep,h,sprintf('Loading...%.f%%',i/forecastStep*100));
end
delete(h);
plot(cell2mat(Forecastdata),'b*');
hold on;
plot(cell2mat(TargetSeries),'r*');
OrijinalTestNumbers = cell2mat(TargetSeries(1,10341:end));
yPredictionNumbers = cell2mat(Forecastdata(1,10341:end));
MAPE = sum(abs(abs(OrijinalTestNumbers-yPredictionNumbers)./OrijinalTestNumbers))/length(OrijinalTestNumbers)*100;
textLabel = sprintf('Test Completed. Forecast MAPE =%f',MAPE);
handles.forecast = Forecastdata;
guidata(hObject, handles);
end


function edtForcast_Callback(hObject, eventdata, handles)
% hObject    handle to edtForcast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtForcast as text
%        str2double(get(hObject,'String')) returns contents of edtForcast as a double
end

% --- Executes during object creation, after setting all properties.
function edtForcast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtForcast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnForcastNumber.
function btnForcastNumber_Callback(hObject, eventdata, handles)
% hObject    handle to btnForcastNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in btnForecastSize.
function btnForecastSize_Callback(hObject, eventdata, handles)
% hObject    handle to btnForecastSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'targetDataPath') == 1
    input = xlsread(handles.targetDataPath);
    TargetSeries=input.';
    TargetSeries=num2cell(TargetSeries);
    weight =handles.weight;
    weight=weight.';
    bestNet = handles.bestNet;
else
    Y = load(handles.loadDataPath);
    bestNet = Y.X.bestNet;
    weight = Y.X.weight;
    weight=weight.';
    TargetSeries = Y.X.targetSeries;
end 
    
forecastStep=str2double(get(handles.edtForcast,'String'));
net = setwb(bestNet,weight);
Forecastdata = TargetSeries;
XX = length(Forecastdata);
YY = cell2mat(Forecastdata);
YY(1,end+forecastStep) = 0;
Forecastdata = num2cell(YY);
h = waitbar(0,'Forecasting...','Name','Training');
for i=1:forecastStep
nets = removedelay(net);
[xs,xis,ais] = preparets(nets,{},{},Forecastdata(1,1:XX));
ys = nets(xs,xis,ais);
Forecastdata(1,XX+1) = ys(1,end);
XX = XX+1;
waitbar(i /forecastStep,h,sprintf('Loading...%.f%%',i/forecastStep*100));
end 
delete(h);
handles.forecast = Forecastdata;
guidata(hObject, handles);
end


function edtNeuron_Callback(hObject, eventdata, handles)
% hObject    handle to edtNeuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNeuron as text
%        str2double(get(hObject,'String')) returns contents of edtNeuron as a double


% --- Executes during object creation, after setting all properties.
end
function edtNeuron_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNeuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnNeuronNum.
function btnNeuronNum_Callback(hObject, eventdata, handles)
% hObject    handle to btnNeuronNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in btnBestNet.
function btnBestNet_Callback(hObject, eventdata, handles)
% hObject    handle to btnBestNet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in feedBackConfirm.
function feedBackConfirm_Callback(hObject, eventdata, handles)
% hObject    handle to feedBackConfirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
threshold = get(handles.Threshold,'String'); %edit1 being Tag of ur edit box
feedbackLimit = get(handles.FeedbackLimit,'String');
manuelFeedback = get(handles.manuelFeedback,'String');
threshold=str2double(threshold);
feedbackLimit=str2double(feedbackLimit);
%manuelFeedback=str2double(manuelFeedback);
B = strrep(manuelFeedback,' ',' ');
C = char(strsplit(B));
D = reshape(str2num(C), 1, [])';
manuelFeedback=D.';
 if (isempty(threshold) || isnan(threshold) || threshold>=1)
   handles.tThreshold = 0.8;
 else
   handles.tThreshold = (threshold);
 end
 if (isempty(feedbackLimit) || isnan(feedbackLimit))
   handles.tfeedbackLimit = 5;
 else
   handles.tfeedbackLimit = (feedbackLimit);
 end
 
 if (isempty(manuelFeedback))
     
 else
   [manuelFeedback] = unique(manuelFeedback,'first');
   handles.tmanuelFeedback = (manuelFeedback);
 end
 guidata(hObject, handles);
end

% --- Executes on button press in btnFeedbackValue.
function btnFeedbackValue_Callback(hObject, eventdata, handles)
% hObject    handle to btnFeedbackValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


function manuelFeedback_Callback(hObject, eventdata, handles)
% hObject    handle to manuelFeedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of manuelFeedback as text
%        str2double(get(hObject,'String')) returns contents of manuelFeedback as a double


% --- Executes during object creation, after setting all properties.
end
function manuelFeedback_CreateFcn(hObject, eventdata, handles)
% hObject    handle to manuelFeedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
% --- Executes on button press in btnFeedLimit.
function btnFeedLimit_Callback(hObject, eventdata, handles)
% hObject    handle to btnFeedLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

function FeedbackLimit_Callback(hObject, eventdata, handles)
% hObject    handle to FeedbackLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FeedbackLimit as text
%        str2double(get(hObject,'String')) returns contents of FeedbackLimit as a double


% --- Executes during object creation, after setting all properties.
end
function FeedbackLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FeedbackLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnThreshold.
function btnThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to btnThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold as text
%        str2double(get(hObject,'String')) returns contents of Threshold as a double


% --- Executes during object creation, after setting all properties.,
end
function Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
% --- Executes on button press in btnTrain.
function btnTrain_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'ttrainLength') == 0 || isempty(handles.ttrainLength)
    handles.ttrainLength = 0.7;
end
if isfield(handles,'ttestLength') == 0 || isempty(handles.ttestLength)
    handles.ttestLength = 0.3;
end
if isfield(handles,'tneuronNumber') == 0 || isempty(handles.tneuronNumber)
    handles.tneuronNumber = 1:10;
end 


if isfield(handles,'testDataPath') == 0
    input = xlsread(handles.targetDataPath);
    TargetSeries=input.';
    testLength=(round(handles.ttestLength*length(TargetSeries)));
    trainLength=(round(handles.ttrainLength*length(TargetSeries)));
    inputLength=length(TargetSeries);
else 
    traind = xlsread(handles.targetDataPath);
    test  = xlsread(handles.testDataPath);
    traind = traind.';
    test = test.';
    TargetSeries = [traind test];
    testLength = length(test);
    trainLength = length(traind);
    inputLength=length(TargetSeries);
    TargetSeries=TargetSeries.';
     
    
end
minMape=500;
%Transpose
if isfield(handles,'tfeedbackDelay') == 0 || isempty(handles.tfeedbackDelay)
    handles.tfeedbackDelay = Autocorrelation(TargetSeries,0.8,5);;
end
    

feedbackDelay = handles.tfeedbackDelay;

TargetSeries=num2cell(TargetSeries);%convert
%For creating Training Series and Test Series
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
h = waitbar(0,'Loading...','Name','Training');

for i=handles.tneuronNumber
hiddenLayerSize = i;
net = narnet(feedbackDelay,hiddenLayerSize,'open',trainFcn);
% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.

[inputs,inputStates,layerStates,targets] = preparets(net,{},{},TargetSeries);
% Setup Division of Data for Training, Validation, Testing
net.trainParam.mu_max=1.00e+27;
net.trainParam.epochs=30;
net.trainParam.max_fail = 1000;
%net.performParam.normalization ='standard';
net.divideFcn = 'divideind';
net.divideParam.trainInd = 1:trainLength;
net.divideParam.testInd  = trainLength+1:inputLength;

% Train the Network
[net tr Ys Es Xf Af] = train(net,inputs,targets,inputStates,layerStates);
OrijinalTestNumbers=cell2mat(inputs);
yPredictionNumbers=cell2mat(Ys);
TMAPE = (sum(abs(abs(OrijinalTestNumbers-yPredictionNumbers)./OrijinalTestNumbers))/length(OrijinalTestNumbers))*100;
% Test the Network
if(minMape >= TMAPE)
    minMape = TMAPE;
    weight  = getwb(net);
    handles.minMape = minMape;
    handles.weight = weight;
    handles.bestInputStates = inputStates;
    handles.bestLayerStates = layerStates;
    handles.bestNet = net;
    handles.bestNeuron = i;
    handles.targetSeries = TargetSeries;
    guidata(hObject, handles);
end
waitbar(i / 10,h,sprintf('Loading...%.2f%%',i/2*100));
end
delete(h);
textLabel = sprintf('Training Completed. Train MAPE =%f',minMape);
set(handles.mapetext,'String',textLabel);
end


function Data_Callback(hObject, eventdata, handles)
% hObject    handle to Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Data as text
%        str2double(get(hObject,'String')) returns contents of Data as a double

end
% --- Executes during object creation, after setting all properties.
function Data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnData.
function btnData_Callback(hObject, eventdata, handles)
% hObject    handle to btnData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile({'*xlsx' ; '*xls'},'Load Target Data');
fullpathname = strcat(pathname,filename);
set(handles.Data,'String',fullpathname);
handles.targetDataPath = fullpathname;
guidata(hObject, handles);
end
function TestData_Callback(hObject, eventdata, handles)
% hObject    handle to TestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestData as text
%        str2double(get(hObject,'String')) returns contents of TestData as a double

end
% --- Executes during object creation, after setting all properties.
function TestData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function TrainData_Callback(hObject, eventdata, handles)
% hObject    handle to TrainData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrainData as text
%        str2double(get(hObject,'String')) returns contents of TrainData as a double

end
% --- Executes during object creation, after setting all properties.
function TrainData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrainData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnTest.
function btnTest_Callback(hObject, eventdata, handles)
% hObject    handle to btnTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --- Executes on button press in btnTrainData.
function btnTrainData_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrainData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --------------------------------------------------------------------
function trainOp_Callback(hObject, eventdata, handles)
% hObject    handle to trainOp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trainOp(handles);
end



function edtTestData_Callback(hObject, eventdata, handles)
% hObject    handle to edtTestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTestData as text
%        str2double(get(hObject,'String')) returns contents of edtTestData as a double

end
% --- Executes during object creation, after setting all properties.
function edtTestData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnTestData.
function btnTestData_Callback(hObject, eventdata, handles)
% hObject    handle to btnTestData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*xlsx' ; '*xls'},'Load Test Data');
fullpathname = strcat(pathname,filename);
set(handles.testData,'String',fullpathname);
handles.testDataPath = fullpathname;
guidata(hObject, handles);
end
function feedbackDelay=Autocorrelation(TargetSeries,threshold,feedbackLimit)
N = length(TargetSeries);
zt = zscore(TargetSeries,1);
autocorrt = nncorr( zt, zt, N-1, 'biased' );
[ sortact FD ] = sort(autocorrt(N:end),2,'descend');
for i=1:length(sortact)
    if(sortact(1,i)>=threshold) 
    feedbackDelay(1,i)=FD(1,i);
    end
end 
[max,maxInd] =findpeaks(autocorrt(N:end));
maxInd = maxInd(1,1:feedbackLimit);
DataInv = 1.01 - autocorrt(N:end);
[Minima,MinIdx] = findpeaks(DataInv);
MinIdx = MinIdx(1,1:feedbackLimit);
feedbackDelay = [feedbackDelay maxInd MinIdx];
[feedbackDelay] = unique(feedbackDelay,'first');
end


% --- Executes on button press in testDataButton.
function testDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to testDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'targetDataPath') == 1
    input = xlsread(handles.targetDataPath);
    TargetSeries=input.';
    testLength=(round(handles.ttestLength*length(TargetSeries)));
    trainLength=(round(handles.ttrainLength*length(TargetSeries)));
    inputLength=length(TargetSeries);
    TargetSeries=num2cell(TargetSeries);
    weight =handles.weight;
    bestNet = handles.bestNet;
    bestInputStates =handles.bestInputStates;
    bestLayerStates =handles.bestLayerStates;
    traindata = TargetSeries(:,1:trainLength);
    testdata = TargetSeries(:,trainLength+1:end);
else 
    Y = load(handles.loadDataPath);
    bestNet = Y.X.bestNet;
    bestInputStates =Y.X.bestInputStates;
    bestLayerStates =Y.X.bestLayerStates;
    weight = Y.X.weight;
    TargetSeries = Y.X.targetSeries;
    testLength=(round(handles.ttestLength*length(TargetSeries)));
    inputLength=length(TargetSeries);
    trainLength=(round(handles.ttrainLength*length(TargetSeries)));
    traindata = TargetSeries(:,1:trainLength);
    testdata = TargetSeries(:,trainLength+1:end);
end
if isfield(handles,'testDataPath') == 1
    input = xlsread(handles.testDataPath);
    testdata=input.';
    testdata=num2cell(testdata);
    Y = load(handles.loadDataPath);
    bestNet = Y.X.bestNet;
    bestInputStates =Y.X.bestInputStates;
    bestLayerStates =Y.X.bestLayerStates;
    weight = Y.X.weight;
end

weight=weight.';
net2 = setwb(bestNet,weight);
bestPredict = net2(testdata,bestInputStates,bestLayerStates);% best all times
OrijinalTestNumbers=cell2mat(testdata);
yPredictionNumbers=cell2mat(bestPredict);

handles.OrijinalTestNumbers = OrijinalTestNumbers;
handles.yPredictionNumbers = yPredictionNumbers;
guidata(hObject, handles);

MAPE=(sum(abs(abs(OrijinalTestNumbers-yPredictionNumbers)./OrijinalTestNumbers))/length(OrijinalTestNumbers))*100;
textLabel = sprintf('Test Completed. Test MAPE =%f',MAPE);
set(handles.mapetext,'String',textLabel);
end
% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
X.bestInputStates = handles.bestInputStates;
X.bestLayerStates = handles.bestLayerStates;
X.bestNet = handles.bestNet;
X.weight = handles.weight;
X.minMape = handles.minMape;
X.bestNeuron = handles.bestNeuron;
X.targetSeries = handles.targetSeries;
[filename,pathname,filter] = uiputfile('animinit.mat','Save file name','*.mat');
fileName = fullfile(pathname, filename);
save(fileName,'X');
end


% --- Executes on button press in loadOldData.
function loadOldData_Callback(hObject, eventdata, handles)
% hObject    handle to loadOldData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile({'*mat'},'Load Old Work');
fullpathname = strcat(pathname,filename);
set(handles.LoadOld,'String',fullpathname);
handles.loadDataPath = fullpathname;
guidata(hObject, handles);
end



function LoadOld_Callback(hObject, eventdata, handles)
% hObject    handle to LoadOld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LoadOld as text
%        str2double(get(hObject,'String')) returns contents of LoadOld as a double

end
% --- Executes during object creation, after setting all properties.
function LoadOld_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadOld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on selection change in listValue.
function listValue_Callback(hObject, eventdata, handles)
% hObject    handle to listValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listValue contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listValue
end

% --- Executes during object creation, after setting all properties.
function listValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in feedBackConfirm.


% --------------------------------------------------------------------
function feedOp_Callback(hObject, eventdata, handles)
% hObject    handle to feedOp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --------------------------------------------------------------------
function loadOp_Callback(hObject, eventdata, handles)
% hObject    handle to loadOp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --------------------------------------------------------------------
function graphicOp_Callback(hObject, eventdata, handles)
% hObject    handle to graphicOp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
