%% Function runSingleLinkSim()
% Parameters
%  K - the number of packets in the application message
%  p - the probability of failure 
%  N - the number of simulations to run
%
% Returns: the average numeric result across the total simulations

function simulatedData = runSingleLinkSim()

close all; %helps a little

K = [1,5,15,50,100];
p = 0:0.01:0.99; %is 100 enough?
N = 1000; %needed?

simulatedData = zeros(length(K), length(p));
calculatedData = zeros(length(K), length(p));

    for x = 1 : length(K)
         for y = 1 : length(p)
             simulatedData(x,y) = createData(K(x),p(y),N);
             calculatedData(x,y) = K(x) / (1 - p(y));
         end
    end

for i = 1 : length(K) %makes 5 graphs, one per K

figure;
semilogy (p,simulatedData(i, :), 'ko', 'color', 'b');
hold on; %fails without
semilogy (p,calculatedData(i, :), 'color', 'r');
title(sprintf('Average Number of Transmissions for K = %d', K(i))); %why does this even work?
xlabel('P(failure)');
ylabel('# of transmissions');
grid;
hold off;

end

end

function result = createData(K,p,N)

    simResults = ones(1,N); % a place to store the result of each simulation
    
    for i=1:N
        txAttemptCount = 0; % transmission count
        pktSuccessCount = 0; % number of packets that have made it across
    
        while pktSuccessCount < K
            
            r = rand; % generate random number to determine if packet is successful (r > p)
            txAttemptCount = txAttemptCount + 1; % count 1st attempt
        
            % while packet transmissions is not successful (r < p)
            while r < p
                r = rand; % transmit again, generate new success check value r
                txAttemptCount = txAttemptCount + 1; % count additional attempt
            end
        
            pktSuccessCount = pktSuccessCount + 1; % increase success count after success (r > p)
        end
    
        simResults(i) = txAttemptCount; % record total number of attempted transmissions before entire application message (K successful packets) transmitted
    end

    result = mean(simResults);
end