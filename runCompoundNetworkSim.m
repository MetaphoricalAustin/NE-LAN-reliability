%% Function runCompoundNetworkSim()
% Parameters
%  K - the number of packets in the application message
%  p - the probability of failure 
%  N - the number of simulations to run
%
% Returns: the average numeric result across the total simulations

function simulatedData = runCompoundNetworkSim()

close all; %helps a little

K = [1,5,15,50,100];
p = 0:0.01:0.99; %is 100 enough?
N = 1000; %needed?

simulatedData = zeros(length(K), length(p));
calculatedData = zeros(length(K), length(p));

    for x = 1 : length(K)
         for y = 1 : length(p)
             simulatedData(x,y) = createData(K(x),p(y),N) * 1000;
             calculatedData(x,y) = (1 / ((1 - (p(y) * p(y))) + (1 - p(y)))) + 1; %1 - ((parallel link) + (series link))
         end
    end

for i = 1 : length(K) %makes 5 graphs, one per K

figure;
semilogy (p,simulatedData(i, :), 'ko', 'color', 'b');
hold on; %fails without
semilogy (p,calculatedData(i, :), 'color', 'r');
title(sprintf('Average Number of Transmissions for K = %d', K(i))); %why does this even work?
xlabel('P(Failure)');
ylabel('# of Transmissions');
grid;
hold off;

end

end

function result = createData(K,p,N)
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

                if r > p %if the link succeeded
                    link1Failure = true;
                end
            
                r = rand; %check and see if the link succeeded

                if r > p %if the link succeeded
                    link2Failure = true;
                end

                if link1Failure || link2Failure %if either link is a success the entire link succeeded
                    parallelLinkSuccess = true;
                end

                %Single link check
                r = rand; % transmit again, generate new success check value r
                if r > p
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