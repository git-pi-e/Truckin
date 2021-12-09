import os
import sys

_, player_agent, num_epochs = sys.argv
num_epochs = int(num_epochs)
wins = 0
draws = 0
losses = 0
epoch = 0

original_stdout = sys.stdout
while epoch <  num_epochs:

    os.system('swipl -s game.pl -g "run_game." -t halt. > game_output.txt')
    f = open('game_output.txt', 'r')

    lines = f.readlines()
    if len(lines) > 7:
        print("epoch: ", epoch +1)
        epoch += 1

        output1 = lines[-6].split()
        output2 = lines[-7].split()

        if output1[0] == 'greedy_agent2':
            output1, output2 = output2, output1
   
        agent1_money = float(output1[-1])
        place1 = output1[3]

        agent2_money = float(output2[-1])
        place2 = output2[3]

        if(player_agent == "greedy_agent1"):
            if (place1 == 'Alices'):

                if (agent1_money > agent2_money):
                    wins += 1 
                elif (agent1_money == agent2_money):
                    draws += 1
                else:
                    losses += 1
            else:
               losses += 1

        elif(player_agent == "greedy_agent2"):
            if (place2 == 'Alices'):

                if (agent1_money < agent2_money):
                    wins += 1 
                elif (agent1_money == agent2_money):
                    draws += 1
                else:
                    losses += 1
            else:
               losses += 1

    f.close()

os.system('rm game_output.txt')
win_text = '"' + "Wins: {}/{}".format(wins,num_epochs) + '"'
draw_text = '"' + "Draws: {}/{}".format(draws,num_epochs) + '"'
loss_text = '"' +  "Losses: {}/{}".format(losses,num_epochs) + '"'
accuracy_text = '"' + "Accuracy: {}".format((float(wins)/num_epochs) * 100) + '"'

os.system('echo ' + win_text + '> output.txt')
os.system('echo ' + draw_text + '>> output.txt')
os.system('echo ' + loss_text + '>> output.txt')
os.system('echo ' + accuracy_text + '>> output.txt')
 
