(deftemplate data
    (slot done-greeting)
    (multislot recommendations)
)

(deftemplate certainty_factor
    (slot cf)
    (slot cf_val)
)

(defglobal
    ?*cf_explosion_high* = 0
    ?*cf_explosion_low* = 0
    ?*cf_temperature_high* = 0
    ?*cf_temperature_low* = 0
    ?*rule_1_cf* = 0.7
    ?*rule_2_cf* = 0.6
    ?*rule_3_cf* = 0.5
    ?*rule_4_cf* = 0.4
)

(defrule ventilation
    =>
    (printout t "========================================================================================" crlf)
    (printout t "Is it has ventilation there? (yes/no)" crlf)
    (bind ?ventilation (read))
    (if (eq ?ventilation yes)
        then
        (assert(ventilation yes)))
    (if (eq ?ventilation no)
         then
         (assert(ventilation no)))
)

(defrule temperature
    =>
    (printout t "Is the environmental temperature high or low? (high/low)" crlf)
    (bind ?temperature (read))
    (if (eq ?temperature high)
        then
        (assert(temperature high))
        (printout t "To what degree do you believe that? (0-1.0)" crlf)
        (bind ?*cf_temperature_high* (float(read))))
    (if (eq ?temperature low)
         then
         (assert(temperature low))
         (printout t "To what degree do you believe that? (0-1.0)" crlf)
         (bind ?*cf_temperature_low* (float(read))))
)

(defrule leakage
    =>
    (printout t "Has there been any leakage of chemical substances? (yes/no)" crlf)
    (bind ?explosion (read))
    (if (eq ?explosion yes)
        then
        (assert (explosion yes))
        (printout t "To what degree do you believe that? (0-1.0)" crlf)
        (bind ?*cf_explosion_high* (float (read))))
    (if (eq ?explosion no)
        then
        (assert (explosion no))
        (printout t "To what degree do you believe that? (0-1.0)" crlf)
        (bind ?*cf_explosion_low* (float (read))))
)
 
(defrule greet
    =>
    (printout t "Welcome to the Chemical Safety System" crlf)
    (printout t "This system aims to provide recommendations to workers or industrial managers in dealing with potential dangers that may arise in the chemical industry." crlf) 
    (printout t "========================================================================================" crlf)
    (assert (data (done-greeting yes)))
) 


(defrule rule_1
    (or(and (explosion yes)
            (temperature high))
       (and (explosion yes)
            (temperature high)
            (ventilation yes)))
    =>
    (bind ?*rule_1_cf* 0.7)
    (printout t "It potentially leading to increased dispersion and evaporation of the chemicals into the environment.")
    (printout t "(cf " (* ?*rule_1_cf* (min ?*cf_explosion_high* ?*cf_temperature_high*)) ")" crlf)
    (printout t "Keep away from the affected area and make sure to inform security personnel immediately." crlf)
)

(defrule rule_2
    (or(and (explosion yes)
            (temperature low))
       (and (explosion yes)
            (temperature low)
            (ventilation yes)))
    =>
    (bind ?*rule_2_cf* 0.6)
    (printout t "It potentially leading to localized concentration and persistence of the substances in the environment.")
    (printout t "(cf " (* ?*rule_2_cf* (min ?*cf_explosion_high* ?*cf_temperature_low*)) ")" crlf)
    (printout t "Keep away from the affected area and make sure to inform security personnel immediately." crlf)
)

(defrule rule_3
    (or(and (explosion no) 
            (temperature high))
       (and (explosion no) 
            (temperature high)
            (ventilation yes)))
    =>
    (bind ?*rule_3_cf* 0.5)
    (printout t "It is leading to potential environmental and health hazards unrelated to leakage.")
    (printout t "(cf " (* ?*rule_3_cf* (min ?*cf_explosion_low* ?*cf_temperature_high*)) ")" crlf)
    (printout t "Stay cautious and make sure to continue monitoring the work environment." crlf)
)

(defrule rule_4
    (or(and (explosion no)
            (temperature low))
       (and (explosion no)
            (temperature low)
            (ventilation yes)))
    =>
    (bind ?*rule_4_cf* 0.4)
    (printout t "It is reducing potential environmental and health hazards associated with chemical leakage.")
    (printout t "(cf " (* ?*rule_4_cf* (min ?*cf_explosion_low* ?*cf_temperature_low*)) ")" crlf)
    (printout t "Continue work as usual and make sure to remain vigilant to any changes in conditions." crlf)
)

(defrule rule_1_ventilation
    (and (explosion yes)
         (temperature high)
         (ventilation no))
    =>
    (bind ?rule_1_ventilation_cf 0.6)
    (printout t "It potentially leading to increased dispersion and evaporation of the chemicals into the environment. ")
    (printout t "(cf " (+ ?*rule_1_cf* (* ?rule_1_ventilation_cf (- 1 ?*rule_1_cf*))) ")" crlf)
    (printout t "Move to a safe location with proper ventilation and inform the relevant authorities." crlf)
)

(defrule rule_2_ventilation
    (and (explosion yes)
         (temperature low)
         (ventilation no))
    =>
    (bind ?rule_2_ventilation_cf 0.5)
    (printout t "It potentially leading to localized concentration and persistence of the substances in the environment.")
    (printout t "(cf " (+ ?*rule_2_cf* (* ?rule_2_ventilation_cf (- 1 ?*rule_2_cf*))) ")" crlf)
    (printout t "Move to a safe location with proper ventilation and inform the relevant authorities." crlf)
)

(defrule rule_3_ventilation
    (and (explosion no)
         (temperature high)
         (ventilation no)) 
    =>
    (bind ?rule_3_ventilation_cf 0.45)
    (printout t "It is leading to potential environmental and health hazards unrelated to leakage.")
    (printout t "(cf " (+ ?*rule_3_cf* (* ?rule_3_ventilation_cf (- 1 ?*rule_3_cf*))) ")" crlf)
    (printout t "Move to a safer area with better ventilation and inform the relevant authorities." crlf)
)

(defrule rule_4_ventilation
    (and (explosion no)
         (temperature low)
         (ventilation no))
    =>
    (bind ?rule_4_ventilation_cf 0.4)
    (printout t "It is reducing potential environmental and health hazards associated with chemical leakage.")
    (printout t "(cf " (+ ?*rule_4_cf* (* ?rule_4_ventilation_cf (- 1 ?*rule_4_cf*))) ")" crlf)
    (printout t "Move to a safer area with better ventilation and inform the relevant authorities." crlf)  
)