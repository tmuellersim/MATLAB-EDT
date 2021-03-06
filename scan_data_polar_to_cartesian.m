%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Strip all information from text file until %
%   only header and scan data remains        % 
%                                            %
% Change file location in script below       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;

%% Initialize variables.
filename = 'C:\Users\Tim\Documents\MATLAB\MATLAB-EDT\scan_sawhorse_test.txt';     % Change this file location!
delimiter = ',';

%% Read columns of data as strings:
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
scan_data = cell2mat(raw);

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;

%% Pull pertinent data from array

[m,n] = size(scan_data);
range_data = scan_data(2:m,12:n);

[j,k] = size(range_data);

time_increment = scan_data(2,9);
time_stamp = (0:time_increment:((j-1)*time_increment))';

angle_min = scan_data(2,5);
angle_max = scan_data(2,6);
angle_increment = scan_data(2,7);

angle = (angle_min:angle_increment:angle_max);

%% Begin Calculations to convert range data from polar to cartesian coordinates

cos_angle = cos(angle);
sin_angle = sin(angle);

ydata = bsxfun(@times,range_data,cos_angle);    % y = r*cos(theta)
xdata = bsxfun(@times,range_data,sin_angle);    % x = r*sin(theta)

xdata = reshape(xdata,[(j*k),1]);
ydata = reshape(ydata,[(j*k),1]);

zdata = reshape(repmat(time_stamp,1,k),[(j*k),1]);  % time data

xdata = xdata*(-1);        % mirrors data about the y-axis
    
%% Plot data

figure;
scatter3(xdata,ydata,zdata,'.');
title('Scan Data');
xlabel('X-Axis [m]');
ylabel('Y-Axis [m]');
zlabel('Time [sec]');
    
view(0,90);         % Top down view
    
    
    
    
    
    
    
    