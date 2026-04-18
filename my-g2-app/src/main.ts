import { 
  waitForEvenAppBridge, 
  TextContainerProperty, 
  CreateStartUpPageContainer,
  type EvenAppBridge
} from '@evenrealities/even_hub_sdk'

// Script data - same as in EvenPlugin
const scripts = [
  {
    id: 'wire-switch',
    title: 'Wire a Three-Way Light Switch',
    category: 'Home DIY',
    risk: 'high',
    steps: [
      'Turn off the breaker controlling the circuit',
      'Verify power is off with a non-contact voltage tester',
      'Remove existing switch plates and switches',
      'Identify the common wire (usually black or marked)',
      'Identify the two traveler wires (usually red and black)',
      'Connect the common wire to the common terminal (dark screw)',
      'Connect traveler wires to the brass traveler terminals',
      'Connect ground wire to green ground screw',
      'Secure wire nuts on all connections',
      'Carefully fold wires into box and mount switch',
      'Repeat at the second switch location',
      'Turn breaker on and test both switches'
    ]
  },
  {
    id: 'openclaw-update',
    title: 'Update OpenClaw via CLI',
    category: 'Software / CLI',
    risk: 'medium',
    steps: [
      'Check current version: openclaw version',
      'Review release notes for breaking changes',
      'Stop the gateway: openclaw gateway stop',
      'Backup config: cp ~/.openclaw/config.json ~/.openclaw/config.json.bak',
      'Run update: openclaw update',
      'Start gateway: openclaw gateway start',
      'Verify status: openclaw status',
      'Check logs: openclaw logs --tail 50'
    ]
  },
  {
    id: 'belay-test',
    title: 'Pass the Lead Belay Gym Test',
    category: 'Climbing / Outdoor',
    risk: 'high',
    steps: [
      'Check climber\'s harness is doubled back at waist and legs',
      'Verify climber\'s tie-in knot is dressed and has backup',
      'Confirm belay device is compatible with rope diameter',
      'Thread rope through belay device correctly (follow diagram)',
      'Lock carabiner through device and harness belay loop',
      'Perform partner check: harness, knot, device, carabiner locked',
      'Establish communication with standard commands',
      'Keep brake hand on rope at all times',
      'Give slack smoothly as climber clips',
      'Take in slack promptly after clips',
      'Never short-rope the climber',
      'Prepare to catch a fall with brake hand locked down'
    ]
  },
  {
    id: 'pesto-pasta',
    title: 'Garden Fresh Pesto Pasta',
    category: 'Cooking',
    risk: 'low',
    steps: [
      'Bring large pot of salted water to boil',
      'Add pasta and cook until al dente (check package time)',
      'While pasta cooks, blend basil, garlic, nuts, and parmesan',
      'Slowly drizzle in olive oil while blending to emulsify',
      'Taste pesto and season with salt if needed',
      'Before draining, reserve 1 cup of pasta water',
      'Drain pasta, saving some cooking water',
      'Toss hot pasta with pesto in the pot',
      'Add pasta water a splash at a time to loosen sauce',
      'Serve immediately with extra parmesan on top'
    ]
  }
];

// State
let bridge: EvenAppBridge | null = null;
let currentScriptIndex = 0;
let currentStepIndex = 0;
let isShowingMenu = true;

// Initialize
async function init() {
  try {
    console.log('Initializing G2 app...');
    bridge = await waitForEvenAppBridge();
    console.log('✅ Connected to G2 glasses!');
    
    // HARDWARE QUIRK: The Even App WebView injects the bridge, but the physical glasses
    // sometimes need a split second to clear their internal buffer before accepting the
    // startup page payload over BLE.
    console.log('Waiting for BLE buffer to clear...');
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log('BLE ready, displaying content');
    
    // Show script menu
    showScriptMenu();
    
    // Set up input handler
    setupInputHandler();
    
  } catch (error) {
    console.error('❌ Failed to initialize:', error);
  }
}

// Show script selection menu
function showScriptMenu() {
  isShowingMenu = true;
  
  const menuText = scripts.map((s, i) => `${i + 1}. ${s.title}`).join('\n');
  const title = '🔌 Jacked Into The Matrix';
  
  displayText(title, menuText, 'Tap: Next script | Double: Select');
}

// Show current step
function showCurrentStep() {
  isShowingMenu = false;
  const script = scripts[currentScriptIndex];
  const step = script.steps[currentStepIndex];
  
  const title = `${script.title}`;
  const subtitle = `Step ${currentStepIndex + 1} of ${script.steps.length}`;
  
  displayText(title, step, subtitle);
}

// Display text on G2
async function displayText(title: string, content: string, footer: string) {
  if (!bridge) return;
  
  // Title container
  const titleContainer = new TextContainerProperty({
    xPosition: 0,
    yPosition: 0,
    width: 576,
    height: 40,
    borderWidth: 0,
    borderColor: 5,
    paddingLength: 4,
    containerID: 1,
    containerName: 'title',
    content: title,
    isEventCapture: 0,
  });
  
  // Main content container
  const contentContainer = new TextContainerProperty({
    xPosition: 0,
    yPosition: 45,
    width: 576,
    height: 200,
    borderWidth: 1,
    borderColor: 5,
    paddingLength: 8,
    containerID: 2,
    containerName: 'content',
    content: content,
    isEventCapture: 1, // Capture events for navigation
  });
  
  // Footer container
  const footerContainer = new TextContainerProperty({
    xPosition: 0,
    yPosition: 250,
    width: 576,
    height: 38,
    borderWidth: 0,
    borderColor: 5,
    paddingLength: 2,
    containerID: 3,
    containerName: 'footer',
    content: footer,
    isEventCapture: 0,
  });
  
  const result = await bridge.createStartUpPageContainer(new CreateStartUpPageContainer({
    containerTotalNum: 3,
    textObject: [titleContainer, contentContainer, footerContainer],
  }));
  
  console.log('Display result:', result === 0 ? 'success' : 'failed');
}

// Set up input handler for G2 touchpads
function setupInputHandler() {
  // Listen for events from G2
  (window as any)._listenEvenAppMessage = (msg: any) => {
    console.log('G2 Input:', msg);
    
    if (isShowingMenu) {
      handleMenuInput(msg);
    } else {
      handleStepInput(msg);
    }
  };
}

// Handle menu navigation
function handleMenuInput(msg: any) {
  if (msg.type === 'BUTTON_SINGLE' || msg.type === 'SWIPE_UP') {
    // Next script
    currentScriptIndex = (currentScriptIndex + 1) % scripts.length;
    showScriptMenu();
  } else if (msg.type === 'BUTTON_DOUBLE' || msg.type === 'SWIPE_DOWN') {
    // Select script
    currentStepIndex = 0;
    showCurrentStep();
  }
}

// Handle step navigation
function handleStepInput(msg: any) {
  const script = scripts[currentScriptIndex];
  
  if (msg.type === 'BUTTON_SINGLE' || msg.type === 'SWIPE_UP') {
    // Next step
    if (currentStepIndex < script.steps.length - 1) {
      currentStepIndex++;
      showCurrentStep();
    } else {
      // Back to menu at end
      showScriptMenu();
    }
  } else if (msg.type === 'BUTTON_DOUBLE' || msg.type === 'SWIPE_DOWN') {
    // Previous step
    if (currentStepIndex > 0) {
      currentStepIndex--;
      showCurrentStep();
    } else {
      // Back to menu at start
      showScriptMenu();
    }
  }
}

// Start the app
init();
