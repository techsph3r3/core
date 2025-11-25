# Interactive Topology Generation Workflow

## User Experience

### Phase 1: Input
- **Text**: User describes network in natural language
- **Image**: User uploads network diagram (hand-drawn, screenshot, etc.)

### Phase 2: Interpretation
- LLM analyzes input and presents structured plan
- Shows:
  - Node count breakdown (routers, switches, hosts)
  - Topology structure
  - Suggested improvements/clarifications
- User can edit the interpretation

### Phase 3: Refinement
- User reviews and modifies:
  - Add missing components ("add switches")
  - Correct misinterpretations ("that's a router, not a switch")
  - Adjust quantities ("make it 10 hosts instead of 5")

### Phase 4: Generation
- User clicks "Generate"
- System creates XML topology
- Auto-loads into CORE GUI

## Example Interaction

**User**: [Uploads sketch showing 3 circles connected in triangle]

**LLM**: "I see 3 nodes connected in a ring. I interpret this as:
- 3 routers in a ring topology
- Each link is a separate /24 subnet
- Total: 3 routers, 3 links

Questions:
- Should I add hosts to each router?
- Do you want switches for LAN segments?"

**User**: "Yes, add a switch to each router with 5 hosts each"

**LLM**: "Updated plan:
- 3 routers in ring (R1, R2, R3)
- 3 switches (S1, S2, S3)
- 15 hosts (5 per switch)
- Total: 6 nodes in backbone, 15 edge hosts = 21 nodes"

**User**: "Generate"

**System**: ✅ Created and loaded into CORE GUI
