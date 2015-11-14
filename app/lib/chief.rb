# A 'chief' instance initiates and coordinates analysis of project data.
# It calls 'Detectives' (analyzers) in the right order, each of which have
# access to the evidence accumulated so far.

# Only the 'chief' decides when to update the proposed changes.

class Chief
  def initialize(project)
    @evidence = Evidence.new(project)
  end

  # TODO: Identify classes automatically and do topological sort.
  ALL_DETECTIVES = [GithubBasicDetective, OssLicenseDetective]

  # Given two changesets, produce merged "best" version
  # When confidence is the same, c1 wins.
  def merge_changeset(c1, c2)
    result = c1.dup
    c2.each do |field, data|
      if !result.key?(field) ||
         (field[:confidence] > result[field][:confidence])
        result[field] = data
      end
    end
    result
  end

  # Should we should update a project's value for 'key'?
  def update_value?(project, key, changeset_data)
    !project.has_attribute?(key) || project[key].blank? ||
      (project[key] == '?') || (changeset_data[:confidence] == 5)
  end

  # Return the best estimates for fields, given project & current proposal.
  def compute_current(fields, project, current_proposal)
    result = {}
    fields.each do |f|
      if update_value?(project, f, current_proposal)
        result[f] = current_proposal[f][:value]
      elsif project.has_attribute?(f)
        result[f] = project[f]
      end
    end
    result
  end

  # Analyze project and reply with a changeset in the form
  # { fieldname1: { value: value, confidence: 1..5, explanation: text}, ...}
  # Do this by determining the right order and way to invoke "detectives"
  # for this project, invoke them, and process their results.
  def propose_changes
    current_proposal = {} # Current best changeset.
    # TODO: Create topographical sort and Real loop over detectives.
    ALL_DETECTIVES.each do |d|
      current_data_for_d = compute_current(d::INPUTS, @evidence.project,
                                           current_proposal)
      result = d.new.analyze(@evidence, current_data_for_d)
      current_proposal = merge_changeset(current_proposal, result)
    end
    current_proposal
  end

  # Given project data, return it with the proposed changeset applied.
  # Note: This should probably be class-level
  def apply_changes(project, changes)
    # TODO: Filter so only final (saveable) criteria are set.
    # TODO: Move explanation into corresponding justification text.
    changes.each do |key, data|
      project[key] = data[:value] if update_value?(project, key, data)
    end
  end

  # Given form data about a project, return an improved version.
  def autofill
    apply_changes(@evidence.project, propose_changes)
  end
end