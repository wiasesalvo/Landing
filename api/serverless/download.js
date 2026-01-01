// Serverless function to proxy downloads from private GitHub Releases
// This allows install scripts to download binaries without exposing GitHub tokens
// Set GITHUB_TOKEN as environment variable in Vercel

export default async function handler(req, res) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { GITHUB_TOKEN } = process.env;

  if (!GITHUB_TOKEN) {
    return res.status(500).json({ error: 'Server configuration missing' });
  }

  try {
    const { version, platform, arch } = req.query;

    if (!version || !platform || !arch) {
      return res.status(400).json({ 
        error: 'Missing required parameters: version, platform, arch' 
      });
    }

    // Validate platform and arch
    const validPlatforms = ['windows', 'linux', 'darwin'];
    const validArchs = ['x64', 'arm64'];
    
    if (!validPlatforms.includes(platform) || !validArchs.includes(arch)) {
      return res.status(400).json({ 
        error: 'Invalid platform or architecture' 
      });
    }

    // Get release from GitHub API
    let releaseUrl;
    if (version === 'latest') {
      releaseUrl = 'https://api.github.com/repos/Persistence-AI/Landing/releases/latest';
    } else {
      releaseUrl = `https://api.github.com/repos/Persistence-AI/Landing/releases/tags/v${version}`;
    }

    const releaseResponse = await fetch(releaseUrl, {
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': `token ${GITHUB_TOKEN}`,
        'User-Agent': 'PersistenceAI-Installer'
      },
    });

    if (!releaseResponse.ok) {
      if (releaseResponse.status === 404) {
        return res.status(404).json({ error: 'Release not found' });
      }
      throw new Error(`GitHub API error: ${releaseResponse.status}`);
    }

    const release = await releaseResponse.json();

    // Find matching asset
    const assetPatterns = [
      new RegExp(`${platform}.*${arch}`, 'i'),
      new RegExp(`${platform}`, 'i'),
      new RegExp(`.*${arch}`, 'i')
    ];

    let asset = null;
    for (const pattern of assetPatterns) {
      asset = release.assets.find(a => pattern.test(a.name) && a.name.endsWith('.zip'));
      if (asset) break;
    }

    if (!asset) {
      return res.status(404).json({ 
        error: 'Asset not found',
        available: release.assets.map(a => a.name)
      });
    }

    // Download asset from GitHub
    const assetResponse = await fetch(asset.url, {
      headers: {
        'Accept': 'application/octet-stream',
        'Authorization': `token ${GITHUB_TOKEN}`,
        'User-Agent': 'PersistenceAI-Installer'
      },
    });

    if (!assetResponse.ok) {
      throw new Error(`Failed to download asset: ${assetResponse.status}`);
    }

    // Stream the file to client
    res.setHeader('Content-Type', 'application/zip');
    res.setHeader('Content-Disposition', `attachment; filename="${asset.name}"`);
    res.setHeader('Content-Length', asset.size);

    // Pipe the response
    const buffer = await assetResponse.arrayBuffer();
    res.send(Buffer.from(buffer));

  } catch (error) {
    console.error('Download error:', error);
    return res.status(500).json({ error: error.message });
  }
}
