%% Function runCustomCompoundNetworkSim()
% Parameters
%  K - the number of packets in the application message
%  p - the probability of failure 
%  N - the number of simulations to run
%
% Returns: the average numeric result across the total simulations

function simulatedData = runCustomCompoundNetworkSim()

close all; %helps a little

K = [1,5,10];
p_99 = 0:0.01:0.99; 
p_1 = zeros(1, length(p_99)) + .01;
p_6 = zeros(1, length(p_99)) + .06;
N = 1000; %needed?

simulatedData = zeros(length(K), length(p_99));
calculatedData = zeros(length(K), length(p_99));

for run = 1 : 6 %run through 6 iterations changing each links p values each time

    if run == 1 %p values for the first set
    link1p = p_1;
    link2p = p_6;
    link3p = p_99;
    end

    if run == 2 %p values for the second set
    link1p = p_6;
    link2p = p_1;
    link3p = p_99;
    end

    if run == 3 %p values for the third set
    link1p = p_1;
    link2p = p_99;
    link3p = p_6;
    end

    if run == 4 %p values for the fourth set
    link1p = p_6;
    link2p = p_99;
    link3p = p_1;
    end

    if run == 5 %p values for the fith set
    link1p = p_99;
    link2p = p_1;
    link3p = p_6;
    end

    if run == 6 %p values for the sixth set
    link1p = p_99;
    link2p = p_6;
    link3p = p_1;
    end

    for x = 1 : length(K)
         for y = 1 : length(p_99)
             simulatedData(x,y) = createData(K(x),link1p(y),link2p(y),link3p(y),N) * 1000;
             calculatedData(x,y) = (1 / ((1 - (link1p(y) * link2p(y))) + (1 - link3p(y)))) + 1; %1 - ((parallel link) + (series link))
         end
    end

for i = 1 : length(K) %makes 3 graphs, one per K

figure;
semilogy (p_99,simulatedData(i, :), 'ko', 'color', 'b');
hold on; %fails without
semilogy (p_99,calculatedData(i, :), 'color', 'r');
title(sprintf('Average # of Transmissions for K = %d', K(i))); %why does this even work?
xlabel('P(Failure)');
ylabel('# of Transmissions');
grid;
hold off;

end

end

end

function result = createData(K,p1,p2,p3,N)
    %booleans for checking link success
    link1Failure = false;   
    link2Failure = false; 
    parallelLinkSuccess = false;
    seriesLinkSuccess = false;

    simResults = ones(1,N); % a place to store the result of each simulation
    
    for i=1:N
        txAttemptCount = 0; % transmission count
        pktSuccessCount = 0; % number of packets that have made it across
    
        while pktSuccessCount < K
            
            while parallelLinkSuccess == false || seriesLinkSuccess == false 

                %parallel link check
                txAttemptCount = txAttemptCount + 1; % count attempt per try on both lines

                r = rand; %check and see if the link succeeded

                if r > p1 %if the link succeeded
                    link1Failure = true;
                end
            
                r = rand; %check and see if the link succeeded

                if r > p2 %if the link succeeded
                    link2Failure = true;
                end

                if link1Failure || link2Failure %if either link is a success the entire link succeeded
                    parallelLinkSuccess = true;
                end

                %Single link check
                r = rand; % transmit again, generate new success check value r
                if r > p3
                    seriesLinkSuccess = true;
                end

                if parallelLinkSuccess == false || seriesLinkSuccess == false %if the link failed reset for the next try
                    link1Failure = false;   
                    link2Failure = false;
                    parallelLinkSuccess = false;
                end

            end

            pktSuccessCount = pktSuccessCount + 1; % increase success count after success (r > p)

        end
    
        simResults(i) = txAttemptCount; % record total number of attempted transmissions before entire application message (K successful packets) transmitted
    end

    result = mean(simResults);
end