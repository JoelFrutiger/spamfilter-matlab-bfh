% Spamfilter 10.03.18
% Vidushi Maillart, Marx Stampfli, Reto Spöhel
fileName = 'SpamFilterData.csv';
formatSpec = '%f%f%f%f%f%f%C';
T = readtable(fileName,'Delimiter',',', ...
'Format',formatSpec);
% First Word
word_A = T.remove;
word_B = T.will;
thrsld_A = 0.41;
thrsld_B = 0.1;


T.data = word_A;
% Histograms
subplot(1,2,1)
histogram(T.data(T.type=='spam'),'BinLimits',[0,6])
title('"!": Spam')
subplot(1,2,2)
histogram(T.data(T.type=='nonspam'),'BinLimits',[0,6])
title('"!": Non-Spam')
% Cross Validation Partition: training set 0.8 and test set 0.2
rng(3); % identical partition each run
I = cvpartition(T.type,'HoldOut',0.2); % I.training, I.test
% Group and sizes of training sets
%Number of spam in traning set
S_A = sum(T.type(I.training)=='spam');
%Number of nonspam in traning set
notS_A = sum(T.type(I.training)=='nonspam');
%Threshhold reached for character and is spam (good)
E_S_A = sum(T.data(I.training)> thrsld_A & T.type(I.training)=='spam');
%Threshhold reached for character and is not spam (not good)
E_notS_A = sum(T.data(I.training)> thrsld_A & T.type(I.training)=='nonspam');
%Threshhold not reached for character and is spam (not good)
notE_S_A = sum(T.data(I.training)<= thrsld_A & T.type(I.training)=='spam');
%Threshold not reached and is not spam (good);
notE_notS_A = sum(T.data(I.training)<= thrsld_A & T.type(I.training)=='nonspam');

%Bayes probability training sets 
p_E_S_A = E_S_A/S_A; 
p_E_notS_A = E_notS_A/notS_A;
p_S_E_A = (p_E_S_A*0.9)/(p_E_S_A*0.9+p_E_notS_A*0.1);

% Confusion Matrix training sets
CM_A = [E_S_A, E_notS_A; notE_S_A, notE_notS_A];

testSet_A = T.data(I.test);


%Second Word

T.data = word_B;

% Group and sizes of training sets
%Number of spam in traning set
S_B = sum(T.type(I.training)=='spam');
%Number of nonspam in traning set
notS_B = sum(T.type(I.training)=='nonspam');
%Threshhold reached for character and is spam (good)
E_S_B = sum(T.data(I.training)> thrsld_B & T.type(I.training)=='spam');
%Threshhold reached for character and is not spam (not good)
E_notS_B = sum(T.data(I.training)> thrsld_B & T.type(I.training)=='nonspam');
%Threshhold not reached for character and is spam (not good)
notE_S_B = sum(T.data(I.training)<= thrsld_B & T.type(I.training)=='spam');
%Threshold not reached and is not spam (good);
notE_notS_B = sum(T.data(I.training)<= thrsld_B & T.type(I.training)=='nonspam');

%Bayes probability training sets 
p_E_S_B = E_S_B/S_B; 
p_E_notS_B = E_notS_B/notS_B;
p_S_E_B = (p_E_S_B*0.9)/(p_E_S_B*0.9+p_E_notS_B*0.1);

% Confusion Matrix training sets
CM_B = [E_S_B, E_notS_B; notE_S_B, notE_notS_B];

testSet_B = T.data(I.test);


% P(S|a und b)
chanceOfSpam = (p_E_S_A * p_E_S_B) / (p_E_S_A * p_E_S_B + p_E_notS_A * p_E_notS_B);
chanceOfSpamRealistic = (p_E_S_A * p_E_S_B * 0.9) / (p_E_S_A * p_E_S_B * 0.9 + 0.1*p_E_notS_A * p_E_notS_B);
disp('Chance of Spam if threshold of 2 specified words is exeeded');
disp(chanceOfSpam);
disp('Chance of Spam if threshold of 2 specified words is exeeded more realistic');
disp(chanceOfSpamRealistic);


% Testing
T.data = T.type;
testSet_SPAM = T.data(I.test);

%
count = size(testSet_A);

countCorrectlyFilteredSpam = 0;
countFalsePositiveSpam = 0;
countSpamPassed = 0;
countNonSpamPassed = 0;

%Loop testset check if spamfilter works
for i = 1:count
    if(testSet_A(i) > thrsld_A && testSet_B(i) > thrsld_B)
        if(testSet_SPAM(i) == 'spam')
            countCorrectlyFilteredSpam = countCorrectlyFilteredSpam + 1;
        else
            countFalsePositiveSpam = countFalsePositiveSpam + 1;
        end    
    else
        if(testSet_SPAM(i) == 'spam')
            countSpamPassed = countSpamPassed + 1;
        else
            countNonSpamPassed = countSpamPassed + 1;
        end 
    end
end


disp('remove, 0.41')
disp('will, 1')

disp('Trainings cm wort A')
CM_A

disp('Trainings cm wort B')
CM_B

disp('Testresultat cm')
disp('CorrectlyFilteredSpam | FalsePositiveSpam ')
disp('SpamPassed | NonSpamPassed ')
CM_TestRes = [countCorrectlyFilteredSpam, countFalsePositiveSpam; countSpamPassed,countNonSpamPassed];
disp(CM_TestRes);














