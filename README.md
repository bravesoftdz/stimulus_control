Validation Project (PCRF)
==================

//

This is a repository to my own stimulus control programs.

Validation Project (PCRF) is an ongoing project and includes a stimulus control program (validation_study) and some simple (hacked) python scripts. The main program (validation_study) was writen in Object Free Pascal and Delphi with the lazarus 1.0.14 IDE and was compiled on ubuntu 13.10 (sancy), but was thought to be cross-plataform.

The python scripts were meant to be interfaces to the Pupil Capture software. Pupil is an open source hardware and software platform to track eye movements (https://github.com/pupil-labs/pupil).

The python script 'gettimestamps.py' is part of a(n ugly) solution to produce a 'timestamp' (Pupil output) data structure sinchronized with some of the stimulus control program events. This structure will be useful for further analysis. 

The script 'timestamps_by_trial.py' ilustrates how to read the data of the file 'timestamps' (an output from the Stimulus Control App).

//

Este é um repositório para os meus próprios programas de controle de estímulo.

Validation Project (PCRF) é um projeto em andamento e inclui um programa de controle de estímulo (Stimulus Control App) e alguns scripts simples em python. O programa principal (validation_study) foi escrito em object pascal com a IDE 'Lazarus 1.2.6' e foi compilado no Ubuntu 13.10, mas foi pensado para ser multi-plataforma.

Os scripts em python foram feitos para serem uma interface para o programa Pupil Capture. Pupil é uma plataforma open source que inclui um hardware e um software de monitoramento de movimentos oculares (https://github.com/pupil-labs/pupil).

O script python 'gettimestamps.py' é parte de uma solução (meio feia) para a produção de uma estrutura de 'timestamps' (Pupil output) sincronizada com alguns eventos do programa de controle de estímulos. Essa estrutura setá útil para análises posteriores.

O script 'timestamps_by_trial.py' ilustra como ler os dados do arquivo 'timestamps' (o arquivo de saída do Stimulus Control App).
