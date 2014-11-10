#! /usr/bin/env ruby

class Segmenter

  # create a new Segementer with a sequence
  # and optionally a maximum number of segments
  def initialize seq, maxk=10
   @seq = seq
   @maxk = maxk
   @p_postition_probs = {}
   load_states
  end

  # Find all charcters in the sequence and store them in
  # the instance variable @states
  def load_states
    @states = Set.new()
    @seq.each{ |c| @states.append(c) }
  end

  # probability the sequence is formed of
  # k segments for all allowable values of k
  def probs_k

  end

  # probability the sequence is formed of
  # k segments
  def prob_k k

  end

  # prior probability of the sequence R
  def prior_R

  end

  # prior probability of having K segments
  def prior_k k

  end

  # prior probability of observing the sequence
  # given there are k segments
  def prob_seq_given_k k
    theta_total = states.length
    part2 = 1
    part1 = Math.factorial(theta_total) / part2
    @k_position_probs[k] = []
    @seq.each do |state|
      part3 = 1
      @states.each do |state|
        part3 = part3 * (Math.factorial(@statecount[state]) + 1)
      end
    end
    
  end



end
