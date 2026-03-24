"""
Enhanced Flask Web Application for AWS Demo
Demonstrates IaaS/PaaS with Elastic Beanstalk and S3
"""

from flask import Flask, render_template, jsonify, request, redirect, url_for, flash
import socket
import os
import boto3
from datetime import datetime
from werkzeug.utils import secure_filename
import uuid
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'demo-secret-key-change-in-production')

# File upload configuration - 16MB max (adjust as needed)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16 MB

# AWS Configuration
S3_BUCKET = os.environ.get('S3_BUCKET_NAME', 'demo-app-bucket')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

logger.info(f"S3_BUCKET_NAME from environment: {S3_BUCKET}")
logger.info(f"AWS_REGION from environment: {AWS_REGION}")

# Initialize AWS clients
try:
    s3_client = boto3.client('s3', region_name=AWS_REGION)
    # Test S3 connection
    s3_client.head_bucket(Bucket=S3_BUCKET)
    logger.info(f"Successfully connected to S3 bucket: {S3_BUCKET}")
except Exception as e:
    logger.error(f"Warning: Could not initialize S3 client: {e}")
    s3_client = None

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'pdf', 'txt'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Error handler for file too large
@app.errorhandler(413)
def request_entity_too_large(error):
    flash('File is too large! Maximum file size is 16MB.')
    return redirect(url_for('home')), 413

@app.route('/')
def home():
    """Home page showing instance information and upload form"""
    return render_template('index.html', s3_bucket=S3_BUCKET)

@app.route('/api/info')
def instance_info():
    """API endpoint returning instance and AWS service information"""
    try:
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
    except:
        hostname = "Unknown"
        local_ip = "Unknown"
    
    # Get uploaded files from S3
    uploaded_files = []
    if s3_client:
        try:
            logger.info(f"Listing objects in bucket: {S3_BUCKET}")
            response = s3_client.list_objects_v2(Bucket=S3_BUCKET, MaxKeys=10)
            logger.info(f"S3 list response: {response.get('KeyCount', 0)} objects found")
            if 'Contents' in response:
                for obj in response['Contents']:
                    # Generate pre-signed URL for PRIVATE S3 buckets (security compliance)
                    # Pre-signed URLs expire after 1 hour
                    try:
                        file_url = s3_client.generate_presigned_url(
                            'get_object',
                            Params={'Bucket': S3_BUCKET, 'Key': obj['Key']},
                            ExpiresIn=3600  # 1 hour
                        )
                    except Exception as e:
                        logger.error(f"Error generating pre-signed URL: {e}")
                        file_url = "#"
                    
                    uploaded_files.append({
                        'name': obj['Key'],
                        'size': obj['Size'],
                        'url': file_url,
                        'last_modified': obj['LastModified'].isoformat()
                    })
        except Exception as e:
            logger.error(f"Error listing S3 objects: {e}", exc_info=True)
    
    info = {
        'hostname': hostname,
        'local_ip': local_ip,
        'timestamp': datetime.now().isoformat(),
        'message': 'Running on AWS Elastic Beanstalk with S3',
        'aws_services': {
            'compute': 'AWS Elastic Beanstalk',
            'storage': 'Amazon S3',
            's3_bucket': S3_BUCKET
        },
        'uploaded_files': uploaded_files
    }
    return jsonify(info)

@app.route('/upload', methods=['POST'])
def upload_file():
    """Handle file upload to S3"""
    logger.info("Upload request received")
    logger.info(f"S3_BUCKET: {S3_BUCKET}")
    logger.info(f"s3_client available: {s3_client is not None}")
    
    if 'file' not in request.files:
        logger.warning("No file in request")
        flash('No file selected')
        return redirect(url_for('home'))
    
    file = request.files['file']
    if file.filename == '':
        logger.warning("Empty filename")
        flash('No file selected')
        return redirect(url_for('home'))
    
    logger.info(f"File received: {file.filename}, content_type: {file.content_type}")
    
    if file and allowed_file(file.filename):
        try:
            # Generate unique filename
            filename = secure_filename(file.filename)
            unique_filename = f"{uuid.uuid4().hex[:8]}_{filename}"
            logger.info(f"Uploading as: {unique_filename}")
            
            # Upload to S3
            if s3_client:
                try:
                    # Reset file pointer to beginning
                    file.stream.seek(0)
                    
                    logger.info(f"Starting upload to bucket: {S3_BUCKET}")
                    s3_client.upload_fileobj(
                        file,
                        S3_BUCKET,
                        unique_filename,
                        ExtraArgs={'ContentType': file.content_type or 'application/octet-stream'}
                    )
                    logger.info(f"Upload successful: {unique_filename}")
                    
                    # Generate pre-signed URL for PRIVATE S3 buckets (security compliance)
                    try:
                        file_url = s3_client.generate_presigned_url(
                            'get_object',
                            Params={'Bucket': S3_BUCKET, 'Key': unique_filename},
                            ExpiresIn=3600  # 1 hour
                        )
                        flash(f'✅ File uploaded successfully! (Pre-signed URL expires in 1 hour)')
                    except Exception as e:
                        logger.error(f"Error generating pre-signed URL: {e}")
                        flash(f'File uploaded but could not generate URL: {str(e)}')
                except Exception as upload_error:
                    logger.error(f"S3 upload error: {upload_error}", exc_info=True)
                    flash(f'Upload failed: {str(upload_error)}')
            else:
                logger.error("S3 client not available")
                flash(f'S3 client not available. Bucket: {S3_BUCKET}')
        except Exception as e:
            logger.error(f"Upload processing error: {e}", exc_info=True)
            flash(f'Upload failed: {str(e)}')
    else:
        logger.warning(f"File type not allowed: {file.filename}")
        flash('File type not allowed')
    
    return redirect(url_for('home'))

@app.route('/health')
def health():
    """Health check endpoint for Elastic Beanstalk"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        's3_configured': s3_client is not None
    })

@app.route('/files')
def list_files():
    """List all files in S3 bucket"""
    files = []
    if s3_client:
        try:
            logger.info(f"Listing all files in bucket: {S3_BUCKET}")
            response = s3_client.list_objects_v2(Bucket=S3_BUCKET)
            if 'Contents' in response:
                for obj in response['Contents']:
                    # Generate pre-signed URL for PRIVATE S3 buckets
                    try:
                        file_url = s3_client.generate_presigned_url(
                            'get_object',
                            Params={'Bucket': S3_BUCKET, 'Key': obj['Key']},
                            ExpiresIn=3600  # 1 hour
                        )
                    except Exception as e:
                        logger.error(f"Error generating pre-signed URL: {e}")
                        file_url = "#"
                    
                    files.append({
                        'name': obj['Key'],
                        'size': obj['Size'],
                        'url': file_url,
                        'last_modified': obj['LastModified'].isoformat()
                    })
        except Exception as e:
            logger.error(f"Error listing files: {e}", exc_info=True)
    
    return jsonify({'files': files})

# Elastic Beanstalk uses port 8080 by default
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
